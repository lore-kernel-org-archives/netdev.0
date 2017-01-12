From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 3/3] mlxsw: pci: Fix EQE structure definition
Date: Thu, 12 Jan 2017 09:10:39 +0100
Message-ID: <1484208639-1890-4-git-send-email-jiri@resnulli.us>
References: <1484208639-1890-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34085 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbdALIKp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 03:10:45 -0500
Received: by mail-wm0-f66.google.com with SMTP id c85so1949928wmi.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 00:10:44 -0800 (PST)
In-Reply-To: <1484208639-1890-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

The event_data starts from address 0x00-0x0C and not from 0x08-0x014. This
leads to duplication with other fields in the Event Queue Element such as
sub-type, cqn and owner.

Fixes: eda6500a987a0 ("mlxsw: Add PCI bus implementation")
Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci_hw.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h b/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h
index d147ddd..0af3338 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h
@@ -209,21 +209,21 @@ MLXSW_ITEM32(pci, eqe, owner, 0x0C, 0, 1);
 /* pci_eqe_cmd_token
  * Command completion event - token
  */
-MLXSW_ITEM32(pci, eqe, cmd_token, 0x08, 16, 16);
+MLXSW_ITEM32(pci, eqe, cmd_token, 0x00, 16, 16);
 
 /* pci_eqe_cmd_status
  * Command completion event - status
  */
-MLXSW_ITEM32(pci, eqe, cmd_status, 0x08, 0, 8);
+MLXSW_ITEM32(pci, eqe, cmd_status, 0x00, 0, 8);
 
 /* pci_eqe_cmd_out_param_h
  * Command completion event - output parameter - higher part
  */
-MLXSW_ITEM32(pci, eqe, cmd_out_param_h, 0x0C, 0, 32);
+MLXSW_ITEM32(pci, eqe, cmd_out_param_h, 0x04, 0, 32);
 
 /* pci_eqe_cmd_out_param_l
  * Command completion event - output parameter - lower part
  */
-MLXSW_ITEM32(pci, eqe, cmd_out_param_l, 0x10, 0, 32);
+MLXSW_ITEM32(pci, eqe, cmd_out_param_l, 0x08, 0, 32);
 
 #endif
-- 
2.7.4
