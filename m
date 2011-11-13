From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: reduce skb truesize by 50%
Date: Sun, 13 Nov 2011 20:42:18 +0100
Message-ID: <1321213338.17837.38.camel@edumazet-laptop>
References: <1320673364.3020.21.camel@bwh-desktop>
	 <1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1320859475.3916.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111109.163708.2156133928191684256.davem@davemloft.net>
	 <1320876183.3272.8.camel@edumazet-laptop>
	 <1320884940.5825.34.camel@edumazet-laptop>
	 <1320937526.307.0.camel@lb-tlvb-eilong.il.broadcom.com>
	 <1320938878.2310.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1320942423.307.10.camel@lb-tlvb-eilong.il.broadcom.com>
	 <1320943512.10042.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321210419.3101.1.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47768 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863Ab1KMTmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 14:42:23 -0500
Received: by wyh15 with SMTP id 15so5278995wyh.19
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2011 11:42:22 -0800 (PST)
In-Reply-To: <1321210419.3101.1.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 13 novembre 2011 =C3=A0 20:53 +0200, Eilon Greenstein a =C3=
=A9crit :

> I=E2=80=99m not sure I=E2=80=99m following the math over here. Assumi=
ng L1 is 64 bytes,
> we need up to 63 bytes to align the start address (assuming SLOB is
> being used) and additional (up to) 63 bytes at the end. That can sum =
up
> to 126 bytes  am I missing something?
>=20

What do you really mean by aligning the end ?

How can both start and end of a frame can be aligned ?

If hardware needs extra room after the end of frame, then we already
have it (since we store struct skb_shared_info here)



I ran following patch and everything is fine here

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/=
ethernet/broadcom/bnx2x/bnx2x.h
index aec7212..ddc94cc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1188,8 +1188,8 @@ struct bnx2x {
 	/* Max supported alignment is 256 (8 shift) */
 #define BNX2X_RX_ALIGN_SHIFT		((L1_CACHE_SHIFT < 8) ? \
 					 L1_CACHE_SHIFT : 8)
-	/* FW use 2 Cache lines Alignment for start packet and size  */
-#define BNX2X_FW_RX_ALIGN		(2 << BNX2X_RX_ALIGN_SHIFT)
+	/* FW use Cache line Alignment for start packet and size  */
+#define BNX2X_FW_RX_ALIGN		(1 << BNX2X_RX_ALIGN_SHIFT)
 #define BNX2X_PXP_DRAM_ALIGN		(BNX2X_RX_ALIGN_SHIFT - 5)
=20
 	struct host_sp_status_block *def_status_blk;
