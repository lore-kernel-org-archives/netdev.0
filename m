From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: multicast: bug or "feature"
Date: Fri, 19 Oct 2007 08:21:51 -0700
Message-ID: <OFDA173EE1.60049F6E-ON88257379.0052A408-88257379.00544DA0@us.ibm.com>
References: <E1IiqGF-0003Vu-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: brian.haley@hp.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	vladislav.yasevich@hp.com (Vlad Yasevich)
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:60047 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756909AbXJSPWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 11:22:03 -0400
In-Reply-To: <E1IiqGF-0003Vu-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote on 10/19/2007 04:43:27 AM:

> Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
> >
> > Now, to figure out what IPv6 does different and why it works.
> > Seems to me that the two should have the same behavior.
> 
> IPv6 on Linux uses a per-interface addressing model as opposed
> to the per-host model used by IPv4.

        For link-local addresses, yes.

        It's really a security feature; the ordinary
case where you'd receive something on an interface that's
using one of your source addresses is when someone is spoofing
you, has a duplicate address, or maybe an (unintentional)
routing loop. All of those are error cases, so dropping a
received packet that claims to be sent by you is a reasonable
thing to do.
        If you're getting link-local source addresses for your
IPv6 multicast packets, that may explain it. The link-local
addresses are required to be unique and valid only for that
link, so IPv6 should not consider a different interface's
link-local address as "local" for a destination address, or
a packet using that source address as bogus.
        For a global address, v4 and v6 use the same rules--
for a destination you can receive it on any interface for
any global address. So, if your source address was a global
IPv6 address and it worked, I'd guess IPv6 just isn't checking
the source address. I don't know that it's required by RFC for
either v4 or v6, though it's probably a good idea.

                                                        +-DLS

