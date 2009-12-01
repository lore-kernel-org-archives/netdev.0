From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: [PATCH] Update embedded copy of ethtool.h from kernel 2.6.30
Date: Tue, 1 Dec 2009 16:17:50 +0100
Message-ID: <20091201151750.GG5694@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:51799 "EHLO
	miranda.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbZLAPR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 10:17:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0c09c1a49cc7b819b33566a49d9901f7cfdd6889 in the Linux kernel
added a new field mdio_support inside the struct ethtool_cmd,
changing the struct size for architectures that does not pad structs.
(for example the CRIS architecture)

This size mismatch lead to the ethtool_cmd struct being written
as 44 bytes in the kernel, but only 43 bytes allocated on stack,
overwriting one byte in the stack frame.

Update the ethtool copy of the definition to match the 2.6.30 kernel.

Signed-off-by: Jesper Nilsson <jesper.nilsson@axis.com>

---
 ethtool-copy.h |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index eadba25..fa92515 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -23,11 +23,14 @@ struct ethtool_cmd {
 	__u8	phy_address;
 	__u8	transceiver;	/* Which transceiver to use */
 	__u8	autoneg;	/* Enable or disable autonegotiation */
+	__u8	mdio_support;
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
 	__u16	speed_hi;
-	__u16	reserved2;
-	__u32	reserved[3];
+	__u8	eth_tp_mdix;
+	__u8	reserved2;
+	__u32	lp_advertising;	/* Features the link partner advertises */
+	__u32	reserved[2];
 };
 
 static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
-- 
1.6.4.GIT

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com
