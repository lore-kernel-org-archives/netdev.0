From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 3/3] drivers/net/irda: fix error return code
Date: Fri, 17 Aug 2012 09:46:58 +0200
Message-ID: <1345189618-13758-4-git-send-email-Julia.Lawall@lip6.fr>
References: <1345189618-13758-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4-relais-sop.national.inria.fr ([192.134.164.105]:59030
	"EHLO mail4-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755141Ab2HQHrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 03:47:09 -0400
In-Reply-To: <1345189618-13758-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

Convert a nonnegative error return code to a negative one, as returned
elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret;
expression e1,e2;
@@

if (ret < 0)
 { ... return ret; }
 ... when != ret = e1
     when forall
*if(...)
 {
  ... when != ret = e2
* return ret;
 }
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/irda/ks959-sir.c    |    1 +
 drivers/net/irda/ksdazzle-sir.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/irda/ks959-sir.c b/drivers/net/irda/ks959-sir.c
index 824e2a9..5f3aeac 100644
--- a/drivers/net/irda/ks959-sir.c
+++ b/drivers/net/irda/ks959-sir.c
@@ -542,6 +542,7 @@ static int ks959_net_open(struct net_device *netdev)
 	sprintf(hwname, "usb#%d", kingsun->usbdev->devnum);
 	kingsun->irlap = irlap_open(netdev, &kingsun->qos, hwname);
 	if (!kingsun->irlap) {
+		err = -ENOMEM;
 		dev_err(&kingsun->usbdev->dev, "irlap_open failed\n");
 		goto free_mem;
 	}
diff --git a/drivers/net/irda/ksdazzle-sir.c b/drivers/net/irda/ksdazzle-sir.c
index 5a278ab..2d4b6a1 100644
--- a/drivers/net/irda/ksdazzle-sir.c
+++ b/drivers/net/irda/ksdazzle-sir.c
@@ -436,6 +436,7 @@ static int ksdazzle_net_open(struct net_device *netdev)
 	sprintf(hwname, "usb#%d", kingsun->usbdev->devnum);
 	kingsun->irlap = irlap_open(netdev, &kingsun->qos, hwname);
 	if (!kingsun->irlap) {
+		err = -ENOMEM;
 		dev_err(&kingsun->usbdev->dev, "irlap_open failed\n");
 		goto free_mem;
 	}
