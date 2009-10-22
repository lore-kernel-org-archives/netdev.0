From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 3/3] netxen: avoid undue board config check
Date: Wed, 21 Oct 2009 22:39:03 -0700
Message-ID: <1256189943-20477-4-git-send-email-dhananjay@netxen.com>
References: <1256189943-20477-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:24201 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751973AbZJVFjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2009 01:39:00 -0400
In-Reply-To: <1256189943-20477-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Old code assumed board config version in the flash to be 1.
When this will get changed by tools, driver just refuses to
attach. This is unnecessary since driver does not have to
parse board config structure directly (maintained by firmware).

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hw.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 3231400..3185a98 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1901,22 +1901,16 @@ netxen_setup_hwops(struct netxen_adapter *adapter)
 
 int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 {
-	int offset, board_type, magic, header_version;
+	int offset, board_type, magic;
 	struct pci_dev *pdev = adapter->pdev;
 
 	offset = NX_FW_MAGIC_OFFSET;
 	if (netxen_rom_fast_read(adapter, offset, &magic))
 		return -EIO;
 
-	offset = NX_HDR_VERSION_OFFSET;
-	if (netxen_rom_fast_read(adapter, offset, &header_version))
-		return -EIO;
-
-	if (magic != NETXEN_BDINFO_MAGIC ||
-			header_version != NETXEN_BDINFO_VERSION) {
-		dev_err(&pdev->dev,
-			"invalid board config, magic=%08x, version=%08x\n",
-			magic, header_version);
+	if (magic != NETXEN_BDINFO_MAGIC) {
+		dev_err(&pdev->dev, "invalid board config, magic=%08x\n",
+			magic);
 		return -EIO;
 	}
 
-- 
1.6.0.2

