From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [PATCH net-next] Removing the unused PAGE_USE_COUNT() macro on ixgbe
 driver
Date: Tue, 10 Feb 2009 16:16:13 -0200
Message-ID: <4991C46D.3030705@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>
To: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:37533 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759AbZBJSQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 13:16:17 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp03.br.ibm.com (8.13.1/8.13.1) with ESMTP id n1AIEfG3023773
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 16:14:41 -0200
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1AJFfaP3371122
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 16:15:42 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1AIGEhH018443
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 16:16:14 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing the unused PAGE_USE_COUNT() macro. Also removing the unused pa=
ges=20
variable at ixgbe_configure_rx() function.

Signed-off-by: Breno Leit=C3=A3o <leitao@linux.vnet.ibm.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

----

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index a3572d1..8c32c18 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1553,9 +1553,6 @@ static void ixgbe_configure_srrctl(struct ixgbe_a=
dapter *adapter, int index)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(index), srrctl);
 }
=20
-#define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
-                           (((S) & (PAGE_SIZE - 1)) ? 1 : 0))
-
 /**
  * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
  * @adapter: board private structure
@@ -1574,7 +1571,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapt=
er *adapter)
 	                  0xA54F2BEC, 0xEA49AF7C, 0xE214AD3D, 0xB855AABE,
 	                  0x6A3E67EA, 0x14364D17, 0x3BED200D};
 	u32 fctrl, hlreg0;
-	u32 pages;
 	u32 reta =3D 0, mrqc;
 	u32 rdrxctl;
 	int rx_buf_len;
@@ -1604,8 +1600,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapt=
er *adapter)
 		hlreg0 |=3D IXGBE_HLREG0_JUMBOEN;
 	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
=20
-	pages =3D PAGE_USE_COUNT(adapter->netdev->mtu);
-
 	rdlen =3D adapter->rx_ring[0].count * sizeof(union ixgbe_adv_rx_desc)=
;
 	/* disable receives while setting up the descriptors */
 	rxctrl =3D IXGBE_READ_REG(hw, IXGBE_RXCTRL);
