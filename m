From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] hdlc: fix compile problem
Date: Wed, 7 Jan 2009 14:13:43 -0800
Message-ID: <20090107141343.3e256119@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Krzysztof =?UTF-8?B?SGHFgmFzYQ==?= <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57466 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762165AbZAGWNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 17:13:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix build problem with hdlc driver. hdlc_null_ops was being referenced
before it was defined!

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wan/hdlc.c	2009-01-07 14:08:43.510247589 -0800
+++ b/drivers/net/wan/hdlc.c	2009-01-07 14:09:39.093495837 -0800
@@ -40,6 +40,8 @@
 
 static const char* version = "HDLC support module revision 1.22";
 
+static const struct header_ops hdlc_null_ops;
+
 #undef DEBUG_LINK
 
 static struct hdlc_proto *first_proto;
@@ -218,8 +220,6 @@ int hdlc_ioctl(struct net_device *dev, s
 	return -EINVAL;
 }
 
-static const struct header_ops hdlc_null_ops;
-
 static void hdlc_setup_dev(struct net_device *dev)
 {
 	/* Re-init all variables changed by HDLC protocol drivers,
