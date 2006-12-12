From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: Fw: [Bugme-new] [Bug 7665] New: getsockopt(IPV6_*CAST_HOPS) returns -1
Date: Tue, 12 Dec 2006 09:08:14 +0100
Message-ID: <200612120908.19378@auguste.remlab.net>
References: <20061211095623.09fb0c40.akpm@osdl.org> <457DD3EB.9030201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 27.mail-out.ovh.net ([213.186.38.137]:45123 "HELO
	27.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750970AbWLLIIc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 03:08:32 -0500
To: Brian Haley <brian.haley@hp.com>
In-Reply-To: <457DD3EB.9030201@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hello,

Le lundi 11 d=E9cembre 2006 22:55, Brian Haley a =E9crit :
> Andrew Morton wrote:
> > Where fd is a socket (datagram or raw) with IPv6 protocol family,
> > getsockopt(fd, IPPROTO_IPV6, IPV6_UNICAST_HOPS, ...) succeeds, but
> > the returned hop limit is -1. connect()'ing the socket first does
> > not solve the problem.
>
> An IPv6 socket's hoplimit value is not set at creation time, instead,
> the hoplimit in an outgoing packet is set dynamically at transmit
> time to one of the following (in this order):
>
> 1. Hoplimit route metric (if set)
> 2. Outgoing interface value (/proc/sys/net/ipv6/conf/ethX/hop_limit)
> 3. Global IPv6 value (/proc/sys/net/ipv6/conf/all/hop_limit)
>
> A setsockopt() value *will* override this.

Relevant standard (RFC 3493) notes:

   The IPV6_UNICAST_HOPS option may be used with getsockopt() to
   determine the hop limit value that the system will use for subsequen=
t
   unicast packets sent via that socket.

I don't reckon -1 could be the hop limit value. IMHO, the value from=20
case 1 (if socket is connected to some destination), otherwise case 2=20
(if bound to a scope interface) or ultimately the default hop limit=20
ought to be returned instead, as it will be most often correct, while=20
the current behavior is always wrong, unless setsockopt() has been used=
=20
first. I don't if some people may think doing a route lookup in=20
getsockopt might be overly expensive, but at least the two other cases=20
should be ok, particularly the last one.

--=20
R=E9mi Denis-Courmont
