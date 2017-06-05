From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/6] mlxsw: pci: Fix size of trap_id field in CQE
Date: Mon,  5 Jun 2017 16:38:29 +0200
Message-ID: <20170605143832.7025-4-jiri@resnulli.us>
References: <20170605143832.7025-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, alexander.h.duyck@intel.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33005 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751373AbdFEOik (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 10:38:40 -0400
Received: by mail-wm0-f67.google.com with SMTP id x3so2973314wme.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 07:38:39 -0700 (PDT)
In-Reply-To: <20170605143832.7025-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The "trap_id" is 9bits long. So far, this was not a problem since we
used only traps with ids that fit into 8bits. But the ACL traps that are
going to be introduced use the 9th bit.

Fixes: eda6500a987a ("mlxsw: Add PCI bus implementation")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Yotam Gigi <yotamg@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci_hw.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h b/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h
index 0af3338..a644120 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci_hw.h
@@ -155,7 +155,7 @@ MLXSW_ITEM32(pci, cqe, byte_count, 0x04, 0, 14);
 /* pci_cqe_trap_id
  * Trap ID that captured the packet.
  */
-MLXSW_ITEM32(pci, cqe, trap_id, 0x08, 0, 8);
+MLXSW_ITEM32(pci, cqe, trap_id, 0x08, 0, 9);
 
 /* pci_cqe_crc
  * Length include CRC. Indicates the length field includes
-- 
2.9.3
