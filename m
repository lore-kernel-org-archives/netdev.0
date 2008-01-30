From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/sunqe.c section fix
Date: Wed, 30 Jan 2008 22:03:39 +0200
Message-ID: <20080130200339.GO29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:40771 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755968AbYA3UDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:03:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following section mismatch:

<--  snip  -->

...
WARNING: drivers/net/sunqe.o(.devinit.text+0x4): Section mismatch in reference from the function qec_sbus_probe() to the function .init.text:qec_ether_init()
...

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/sunqe.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

bee65cb0dd698bbda02b1087bffed51e3a2488cb 
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index ff23c64..e811331 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -747,7 +747,7 @@ static inline void qec_init_once(struct sunqec *qecp, struct sbus_dev *qsdev)
 		    qecp->gregs + GLOB_RSIZE);
 }
 
-static u8 __init qec_get_burst(struct device_node *dp)
+static u8 __devinit qec_get_burst(struct device_node *dp)
 {
 	u8 bsizes, bsizes_more;
 
@@ -767,7 +767,7 @@ static u8 __init qec_get_burst(struct device_node *dp)
 	return bsizes;
 }
 
-static struct sunqec * __init get_qec(struct sbus_dev *child_sdev)
+static struct sunqec * __devinit get_qec(struct sbus_dev *child_sdev)
 {
 	struct sbus_dev *qec_sdev = child_sdev->parent;
 	struct sunqec *qecp;
@@ -823,7 +823,7 @@ fail:
 	return NULL;
 }
 
-static int __init qec_ether_init(struct sbus_dev *sdev)
+static int __devinit qec_ether_init(struct sbus_dev *sdev)
 {
 	static unsigned version_printed;
 	struct net_device *dev;

