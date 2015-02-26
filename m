From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 4/4] sh_eth: Really fix padding of short frames on TX
Date: Thu, 26 Feb 2015 14:21:42 +0000
Message-ID: <1424960502.4444.22.camel@xylophone.i.decadent.org.uk>
References: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Violeta =?ISO-8859-1?Q?Men=E9ndez_Gonz=E1lez?=
	<violeta.menendez@codethink.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:34962 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbbBZOVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:21:47 -0500
In-Reply-To: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My previous fix to clear padding of short frames used skb->len as the
DMA length, assuming that skb_padto() extended skb->len to include the
padding.  That isn't the case; we need to use skb_put_padto() instead.

(This wasn't immediately obvious because software padding isn't
actually needed on the R-Car H2.  We could make it conditional on
which chip is being driven, but it's probably not worth the effort.)

Reported-by: "Violeta Men=C3=A9ndez Gonz=C3=A1lez" <violeta.menendez@co=
dethink.co.uk>
=46ixes: 612a17a54b50 ("sh_eth: Fix padding of short frames on TX")
Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethern=
et/renesas/sh_eth.c
index 317722e16043..07c537d900da 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2178,7 +2178,7 @@ static int sh_eth_start_xmit(struct sk_buff *skb,=
 struct net_device *ndev)
 	}
 	spin_unlock_irqrestore(&mdp->lock, flags);
=20
-	if (skb_padto(skb, ETH_ZLEN))
+	if (skb_put_padto(skb, ETH_ZLEN))
 		return NETDEV_TX_OK;
=20
 	entry =3D mdp->cur_tx % mdp->num_tx_ring;
--=20
1.7.10.4
