From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next PATCH 01/11] ixgbe: Return error on failure to allocate
 mac_table
Date: Mon, 02 Nov 2015 17:09:29 -0800
Message-ID: <20151103010929.28233.47017.stgit@localhost.localdomain>
References: <20151103005850.28233.63113.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33467 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624AbbKCBJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 20:09:31 -0500
Received: by pabfh17 with SMTP id fh17so2106570pab.0
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 17:09:30 -0800 (PST)
In-Reply-To: <20151103005850.28233.63113.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a check to make certain mac_table was actually allocated and is not
NULL.  If it is NULL return -ENOMEM and allow the probe routine to fail
rather then causing a NULL pointer dereference further down the line.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a5abcb2f9cbd..af5f367a1a22 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5381,6 +5381,8 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->mac_table = kzalloc(sizeof(struct ixgbe_mac_addr) *
 				     hw->mac.num_rar_entries,
 				     GFP_ATOMIC);
+	if (!adapter->mac_table)
+		return -ENOMEM;
 
 	/* Set MAC specific capability flags and exceptions */
 	switch (hw->mac.type) {
