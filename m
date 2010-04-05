From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sky2: rx hash offload
Date: Mon, 05 Apr 2010 18:14:57 +0200
Message-ID: <1270484097.4722.164.camel@edumazet-laptop>
References: <20100405084800.3bcec66a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:32839 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008Ab0DEQPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 12:15:01 -0400
Received: by bwz1 with SMTP id 1so2886944bwz.21
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 09:15:00 -0700 (PDT)
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
>=20

Cool :)

I believe some bits are needed in receive_copy() to transfert rxhash to
new skb ?


diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index d8ec4c1..f420255 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2295,6 +2295,8 @@ static struct sk_buff *receive_copy(struct sky2_p=
ort *sky2,
                skb_copy_from_linear_data(re->skb, skb->data, length);
                skb->ip_summed =3D re->skb->ip_summed;
                skb->csum =3D re->skb->csum;
+               skb->rxhash =3D re->skb->rxhash;
+               re->skb->rxhash =3D 0;
                pci_dma_sync_single_for_device(sky2->hw->pdev, re->data=
_addr,
                                               length, PCI_DMA_FROMDEVI=
CE);
                re->skb->ip_summed =3D CHECKSUM_NONE;


