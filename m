From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] drivers/net/mac8390.c: make functions static
Date: Tue, 10 Jun 2008 01:23:39 +0300
Message-ID: <20080609222339.GQ1987@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:41015 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760281AbYFIWYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 18:24:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the following needlessly global functions static:
- mac8390_ident()
- mac8390_testio()
- mac8390_memsize()

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/mac8390.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

18c761bacda64a735237576da9cb659830d64003 diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index 9e70074..331292d 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -117,8 +117,6 @@ enum mac8390_access {
 	ACCESS_16,
 };
 
-extern enum mac8390_type mac8390_ident(struct nubus_dev * dev);
-extern int mac8390_memsize(unsigned long membase);
 extern int mac8390_memtest(struct net_device * dev);
 static int mac8390_initdev(struct net_device * dev, struct nubus_dev * ndev,
 			   enum mac8390_type type);
@@ -163,7 +161,7 @@ static void slow_sane_block_output(struct net_device *dev, int count,
 static void word_memcpy_tocard(void *tp, const void *fp, int count);
 static void word_memcpy_fromcard(void *tp, const void *fp, int count);
 
-enum mac8390_type __init mac8390_ident(struct nubus_dev * dev)
+static enum mac8390_type __init mac8390_ident(struct nubus_dev *dev)
 {
 	switch (dev->dr_sw) {
 		case NUBUS_DRSW_3COM:
@@ -234,7 +232,7 @@ enum mac8390_type __init mac8390_ident(struct nubus_dev * dev)
 	return MAC8390_NONE;
 }
 
-enum mac8390_access __init mac8390_testio(volatile unsigned long membase)
+static enum mac8390_access __init mac8390_testio(volatile unsigned long membase)
 {
 	unsigned long outdata = 0xA5A0B5B0;
 	unsigned long indata =  0x00000000;
@@ -252,7 +250,7 @@ enum mac8390_access __init mac8390_testio(volatile unsigned long membase)
 	return ACCESS_UNKNOWN;
 }
 
-int __init mac8390_memsize(unsigned long membase)
+static int __init mac8390_memsize(unsigned long membase)
 {
 	unsigned long flags;
 	int i, j;

