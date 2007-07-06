From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH net-2.6.23 take2] UDP: Cleanup UDP encapsulation code
Date: Fri, 6 Jul 2007 10:55:17 +0300
Message-ID: <200707061055.17951.remi.denis-courmont@nokia.com>
References: <200707051618.l65GIh0J030375@quickie.katalix.com> <200707051951.03619@auguste.remlab.net> <468D299E.5070902@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext James Chapman" <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([131.228.20.171]:63464 "EHLO
	mgw-ext12.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757119AbXGFHzn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 03:55:43 -0400
In-Reply-To: <468D299E.5070902@katalix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 05 July 2007 20:25:50 ext James Chapman wrote:
> R=E9mi Denis-Courmont wrote:
> > By the way, couldn't encap_type be remove altogether (using two sli=
ghtly
> > different callbacks for ESP) from udp_sock?
>
> The notion of encap_type is needed for the setsockopt call so it woul=
d
> have to stay in the API. If it were removed from udp_sock, getsockopt
> would have to derive the encap_type from encap_rcv funcptr values, wh=
ich
> would be messy. I think it might complicate the logic in ESP too.

Right. By the way, shouldn't "len" rather be signed in there?

		unsigned int len;

		/* if we're overly short, let UDP handle it */
		len =3D skb->len - sizeof(struct udphdr);
		if (len <=3D 0)
			goto udp;


Regards,

--=20
R=E9mi Denis-Courmont
