From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 0/8] amd-xgbe: AMD XGBE driver updates 2014-11-20
Date: Thu, 20 Nov 2014 11:03:20 -0600
Message-ID: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0103.outbound.protection.outlook.com ([157.56.111.103]:48928
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756934AbaKTRD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 12:03:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes functional updates to the
driver as well as some trivial changes.

- Add a read memory barrier in the Tx and Rx path after checking the
  descriptor ownership bit
- Wait for the Tx engine to stop/suspend before issuing a stop command
- Implement a smatch tool suggestion to simplify an if statement
- Separate out Tx and Rx ring data fields into their own structures
- Add BQL support
- Remove an unused variable
- Change Tx coalescing support to operate on packet basis instead of
  a descriptor basis
- Add support for the skb->xmit_more flag

This patch series is based on net-next.

---

Tom Lendacky (8):
      amd-xgbe: Add a read memory barrier to Tx/Rx path
      amd-xgbe: Tx engine must not be active before stopping it
      amd-xgbe: Incorporate Smatch coding suggestion
      amd-xgbe: Separate Tx/Rx ring data fields into new structs
      amd-xgbe: Add BQL support
      amd-xgbe: Remove unused variable
      amd-xgbe: Perform Tx coalescing on a packet basis
      amd-xgbe: Add support for the skb->xmit_more flag


 drivers/net/ethernet/amd/xgbe/xgbe-common.h |   21 ++-
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c   |   40 +++---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |  170 +++++++++++++++++++++------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c    |  112 ++++++++++++++----
 drivers/net/ethernet/amd/xgbe/xgbe.h        |   42 ++++++-
 5 files changed, 289 insertions(+), 96 deletions(-)

-- 
Tom Lendacky
