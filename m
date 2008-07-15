From: Brandon Philips <brandon@ifup.org>
Subject: [RFC] ethtool: Expand ethtool_cmd.speed to 32 bits
Date: Tue, 15 Jul 2008 02:18:41 -0700
Message-ID: <20080715091841.GA6553@potty.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:35908 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753721AbYGOBMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 21:12:42 -0400
Received: by wf-out-1314.google.com with SMTP id 27so5123071wfd.4
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 18:12:40 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce the speed_hi field to ethtool_cmd, using the reserved space,
to expand the speed field to 2^32 Megabits/second.

Making this field expansion now gives us plenty of time to fix up the
user-space pieces that use SIOCETHTOOL before hardware faster than 64
Gb/s is available.

Signed-off-by: Brandon Philips <bphilips@suse.de>

---
 include/linux/ethtool.h |   17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/ethtool.h
===================================================================
--- linux-2.6.orig/include/linux/ethtool.h
+++ linux-2.6/include/linux/ethtool.h
@@ -27,9 +27,24 @@ struct ethtool_cmd {
 	__u8	autoneg;	/* Enable or disable autonegotiation */
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
-	__u32	reserved[4];
+	__u16	speed_hi;
+	__u16	reserved2;
+	__u32	reserved[3];
 };
 
+static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
+						__u32 speed)
+{
+
+	ep->speed = (__u16)speed;
+	ep->speed_hi = (__u16)(speed >> 16);
+}
+
+static inline __u32 ethtool_cmd_speed(struct ethtool_cmd *ep)
+{
+	return (ep->speed_hi << 16) | ep->speed;
+}
+
 #define ETHTOOL_BUSINFO_LEN	32
 /* these strings are set to whatever the driver author decides... */
 struct ethtool_drvinfo {
