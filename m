From: Szilveszter Ordog <slipszi@gmail.com>
Subject: [PATCH] tg3: receive packets larger than MTU but smaller than 1500
	bytes
Date: Tue, 23 Feb 2010 12:56:26 +0100
Message-ID: <ac67d9131002230356h7d293a5yba011698302f8c4a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:56984 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879Ab0BWL4d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 06:56:33 -0500
Received: by fg-out-1718.google.com with SMTP id e21so856436fga.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2010 03:56:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows for proper ICMP needs fragmentation responses on standard E=
thernet
networks.

Signed-off-by: Szilveszter =D6rd=F6g <slipszi@gmail.com>
---
 drivers/net/tg3.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 46a3f86..0c5027b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -93,6 +93,8 @@
 #define TG3_MIN_MTU			60
 #define TG3_MAX_MTU(tp)	\
 	((tp->tg3_flags2 & TG3_FLG2_JUMBO_CAPABLE) ? 9000 : 1500)
+#define TG3_MAX_RX_MTU(tp) \
+	max(tp->dev->mtu, (unsigned int)ETH_DATA_LEN)

 /* These numbers seem to be hard coded in the NIC firmware somehow.
  * You can't change the ring sizes, but you can change where you place
@@ -4532,7 +4534,7 @@ static int tg3_rx(struct tg3 *tp, int budget)

 		skb->protocol =3D eth_type_trans(skb, tp->dev);

-		if (len > (tp->dev->mtu + ETH_HLEN) &&
+		if (len > (TG3_MAX_RX_MTU(tp) + ETH_HLEN) &&
 		    skb->protocol !=3D htons(ETH_P_8021Q)) {
 			dev_kfree_skb(skb);
 			goto next_pkt;
@@ -6979,7 +6981,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset=
_phy)

 	/* MTU + ethernet header + FCS + optional VLAN tag */
 	tw32(MAC_RX_MTU_SIZE,
-	     tp->dev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
+	     TG3_MAX_RX_MTU(tp) + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);

 	/* The slot time is changed by tg3_setup_phy if we
 	 * run at gigabit with half duplex.
--=20
1.6.3.3
