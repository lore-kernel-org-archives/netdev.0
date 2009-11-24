From: Stefan Assmann <sassmann@redhat.com>
Subject: [PATCH] igb: fix misinterpreted return value of pci_enable_msix
Date: Tue, 24 Nov 2009 11:31:26 +0100
Message-ID: <4B0BB5FE.2000907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@redhat.com>, alexander.h.duyck@intel.com,
	davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21174 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932610AbZKXKbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 05:31:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@redhat.com>

In the igb driver a return value of 0 of function pci_enable_msix is
interpreted as an error case. The correct behaviour is to check < 0 for error
values.

Signed-off-by: Stefan Assmann <sassmann@redhat.com>
---
 drivers/net/igb/igb_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index bb1a6ee..745481d 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -694,7 +694,7 @@ static void igb_set_interrupt_capability(struct igb_adapter *adapter)
 	err = pci_enable_msix(adapter->pdev,
 			      adapter->msix_entries,
 			      numvecs);
-	if (err == 0)
+	if (err < 0)
 		goto out;

 	igb_reset_interrupt_capability(adapter);
-- 
1.6.5.2

