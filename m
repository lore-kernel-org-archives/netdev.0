From: "pradeep singh" <pradeep.rautela@gmail.com>
Subject: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer dereferencing
Date: Thu, 21 Jun 2007 17:30:10 +0530
Message-ID: <a901b49a0706210500g43a4c4a5y19c9ddbd83a50828@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:11672 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918AbXFUMAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 08:00:11 -0400
Received: by py-out-1112.google.com with SMTP id a29so918645pyi
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2007 05:00:11 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Chelsio's in kernel 10G driver does not checks the return value from
t1_get_board_info() in cxgb2.c.
t1_get_board_info may return a NULL and we still go on to dereference
it in the for loop without checking for the NULL.

This patch fixes this.

Signed-off-by: Pradeep Singh <pradeep.rautela@gmail.com>
---
 drivers/net/chelsio/cxgb2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 231ce43..edcfeba 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1023,7 +1023,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 	mmio_len = pci_resource_len(pdev, 0);
 	bi = t1_get_board_info(ent->driver_data);

-	for (i = 0; i < bi->port_number; ++i) {
+	for (i = 0; bi && i < bi->port_number; ++i) {
 		struct net_device *netdev;

 		netdev = alloc_etherdev(adapter ? 0 : sizeof(*adapter));
-- 
1.4.4.2
Thanks

-- 
Pradeep
