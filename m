From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 2/20] drivers/net/ethernet/natsemi/natsemi.c: fix error return code
Date: Wed,  3 Oct 2012 18:17:52 +0200
Message-ID: <1349281090-10013-2-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, romieu@fr.zoreil.com,
	rick.jones2@hp.com, netdev@pradeepdalvi.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:62261 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933018Ab2JCQSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 12:18:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Senna Tschudin <peter.senna@gmail.com>

Convert a nonnegative error return code to a negative one, as returned
elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/net/ethernet/natsemi/natsemi.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 5b61d12..dbaaa99 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -947,8 +947,8 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	i = register_netdev(dev);
 	if (i)
 		goto err_register_netdev;
-
-	if (NATSEMI_CREATE_FILE(pdev, dspcfg_workaround))
+	i = NATSEMI_CREATE_FILE(pdev, dspcfg_workaround);
+	if (i)
 		goto err_create_file;
 
 	if (netif_msg_drv(np)) {
