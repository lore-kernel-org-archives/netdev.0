From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sky2: rx hash offload
Date: Tue, 06 Apr 2010 14:33:30 +0200
Message-ID: <1270557210.2081.8.camel@edumazet-laptop>
References: <20100405084800.3bcec66a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:54496 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754256Ab0DFMdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 08:33:38 -0400
Received: by bwz1 with SMTP id 1so3554610bwz.21
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 05:33:35 -0700 (PDT)
In-Reply-To: <20100405084800.3bcec66a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 avril 2010 =C3=A0 08:48 -0700, Stephen Hemminger a =C3=A9cr=
it :
> Marvell Yukon 2 hardware supports hardware receive hash calculation.
> Now that Receive Packet Steering is available, add support
> to enable it.
>=20
> Note: still experimental, tested on only a few variants.
> No performance testing has been done.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
>  drivers/net/sky2.c |   75 ++++++++++++++++++++++++++++++++++++++++++=
+++++++++--
>  drivers/net/sky2.h |   23 ++++++++++++++++
>  2 files changed, 96 insertions(+), 2 deletions(-)

I am wondering if introducing hardware computed rxhash wouldnt force us
to clear rxhash in several paths (tunneling...), so that we perform a
software recompute after decapsulation, to enable RFS

Not mandatory but recommended I would say...

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 2f302d3..3f0aba4 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -379,6 +379,7 @@ static int ipip_rcv(struct sk_buff *skb)
 		skb_dst_drop(skb);
 		nf_reset(skb);
 		ipip_ecn_decapsulate(iph, skb);
+		skb->rxhash =3D 0;
 		netif_rx(skb);
 		rcu_read_unlock();
 		return 0;


