From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: Unexpected source address selection in routing
Date: Mon, 25 Aug 2008 08:37:50 +0200
Message-ID: <BAY103-DAV12061EF45C1BD09C570A4B2670@phx.gbl>
References: <alpine.LNX.1.10.0808241936410.22921@fbirervta.pbzchgretzou.qr> <20080824.173146.28446297.davem@davemloft.net> <alpine.LNX.1.10.0808242126540.22921@fbirervta.pbzchgretzou.qr>
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>
To: "Jan Engelhardt" <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s18.bay0.hotmail.com ([65.54.246.218]:24558 "EHLO
	bay0-omc3-s18.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751395AbYHYGj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 02:39:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:

>
> On Sunday 2008-08-24 20:31, David Miller wrote:
> >
> >> It appears that the routing code selects the outgoing source
address to
> >> use for packets is chosen when the socket is established instead of
> >> at routing time.
> >>
> >> The following presents a test case for "unexpected" (from a user's
> >> perspective) behavior.
> >>
> >> Is there any way to make it behave as a user would expect?
> >
> >No matter when we had made the routing lookup, we would have ended
> >up with what you see the kernel doing.
> >
> >The route is looked up long before netfilter even sees the packets.
> >
> >The source address selection at the socket level can only "see" the
> >original destination address and therefore makes the source address
> >selection using that original destination address.
>
> That's what I thought. With IPv4, one can cheat and use
> SNAT/MASQUERADE, but what about IPv6? (Other than using the RAWNAT
> extension, which bypasses netfilter connection tracking.)

Just for records, I opened a bug report (a feature request) about
this at http://bugzilla.kernel.org/show_bug.cgi?id=9767


