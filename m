From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Tue, 19 Jul 2011 22:02:18 +0200
Message-ID: <1311105738.3113.11.camel@edumazet-laptop>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47297 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab1GSUCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 16:02:23 -0400
Received: by wyg8 with SMTP id 8so3038328wyg.19
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 13:02:22 -0700 (PDT)
In-Reply-To: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 juillet 2011 =C3=A0 15:52 -0400, Neil Horman a =C3=A9crit :
> This oops was reported recently when running a pktgen script that cal=
led for a
> transmitted skb to be cloned and sent 100 times using the clone_skb c=
ommand to a
> bridge device with several attached interface:
>=20
=2E..

> Turns out the pktgen driver doesn't actually clone skbs, but rather s=
hares them,
> increasing the reference count of the skb for each send operation.  T=
his works
> for most drivers because most drivers don't store or care about any s=
tate in the
> skb itself, but several do.  For instance, the above tun/tap driver a=
nd other
> soft drivers (vlans, bonding/bridging), all requeue frames to a physi=
cal device,
> meaning the skb next and prev pointers will be set.  Other drivers al=
so care
> about skb state.  The virtio_net driver for instance uses the skb->cb=
 space to
> store a vnet header and several converged adapters adjust the data po=
inter of an
> skb to prepend a device control header to the skb.  Drivers expect sk=
bs
> submitted for i/o to be in their control and unshared with other user=
s, an
> assumption which pktgen is violating, the result being multiple skb u=
sers
> corrupting one antohers state and producing oopses like the one above=
=2E  The
> solution is to make pktgen clone the skb for each transmit so as to e=
nsure the
> drivers assumptions about private exclusive access to the skb is main=
tained.
>=20
> Tested successfully by myself
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Jiri Pirko <jpirko@redhat.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Alexey Dobriyan <adobriyan@gmail.com>
> CC: David S. Miller <davem@davemloft.net>
> ---

This will kill pktgen performance ?

pktgen is only for sysadmins, and very skilled ones :)

BTW you forgot to CC pktgen author, Robert Olsson



