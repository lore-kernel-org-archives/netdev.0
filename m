From: Brice Goglin <brice@myri.com>
Subject: [PATCH 6/7] myri10ge: fix big_bytes in case of vlan frames
Date: Mon, 11 Dec 2006 11:27:19 +0100
Message-ID: <457D3287.7050701@myri.com>
References: <457D31B2.30505@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:42250 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762757AbWLKK1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 05:27:38 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <457D31B2.30505@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix sizing of big_bytes in the case of vlan frames. The 4
VLAN_HLEN bytes were omitted, leading to sizing the big buffer
4 bytes smaller than it should be.  Due to how rx buffers are
carved from pages, this was harmless for the common (9000, 1500)
byte MTUs, but could lead to data corruption for some MTUs.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2006-12-11 10:52:51.000000000 +0100
+++ linux-git/drivers/net/myri10ge/myri10ge.c	2006-12-11 10:53:06.000000000 +0100
@@ -1696,11 +1696,11 @@
 	 * tell him the buffer is larger, because we only use 1
 	 * buffer/pkt, and the mtu will prevent overruns.
 	 */
-	big_pow2 = dev->mtu + ETH_HLEN + MXGEFW_PAD;
+	big_pow2 = dev->mtu + ETH_HLEN + VLAN_HLEN + MXGEFW_PAD;
 	if (big_pow2 < MYRI10GE_ALLOC_SIZE / 2) {
 		while ((big_pow2 & (big_pow2 - 1)) != 0)
 			big_pow2++;
-		mgp->big_bytes = dev->mtu + ETH_HLEN + MXGEFW_PAD;
+		mgp->big_bytes = dev->mtu + ETH_HLEN + VLAN_HLEN + MXGEFW_PAD;
 	} else {
 		big_pow2 = MYRI10GE_ALLOC_SIZE;
 		mgp->big_bytes = big_pow2;


