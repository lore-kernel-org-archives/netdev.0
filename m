From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] cls_flow: Add tunnel support to the flow classifier
Date: Mon, 17 Oct 2011 08:40:23 +0200
Message-ID: <1318833623.2500.45.camel@edumazet-laptop>
References: <1318806373.7169.35.camel@ganymede>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Dan Siemon <dan@coverfire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41200 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269Ab1JQGka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 02:40:30 -0400
Received: by wyg36 with SMTP id 36so1845930wyg.19
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2011 23:40:28 -0700 (PDT)
In-Reply-To: <1318806373.7169.35.camel@ganymede>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 16 octobre 2011 =C3=A0 19:06 -0400, Dan Siemon a =C3=A9crit=
 :
> When used on an interface carrying tunneled traffic the flow classifi=
er
> can't look into the tunnels so all of the traffic within the tunnel i=
s
> treated as a single flow. This does not allow any type of intelligent
> queuing to occur. This patch adds new keys to the flow classifier whi=
ch
> look inside the tunnel. Presently IP-IP, IP-IPv6, IPv6-IPv6 and IPv6-=
IP
> tunnels are supported.
>=20
> If you are interested I have posted some background and experimental
> results at:
> http://www.coverfire.com/archives/2011/10/16/making-the-linux-flow-cl=
assifier-tunnel-aware/
>=20
> The related iproute2 patch can be found at the above URL as well.
>=20
> Signed-off-by: Dan Siemon <dan@coverfire.com>
>=20

Hi Dan

You're adding a lot of code (omitting the diffstat :( ) for a specific
usage, yet GRE tunnels are not supported.

IPv6 part is also a bit limited : It assumes TCP/UDP headers are the
first ones. Maybe its time to use ipv6_skip_exthdr() ?

Note also that if we pull (with pskb_network_may_pull()) too many bytes=
,
we kill routing performance on paged frags devices, wich are now
becoming very common.

Adding tunnel support and deep packet inspection might require the use
of skb_header_pointer() wich does the copy of needed data without
requiring expensive reallocation of skb head.
