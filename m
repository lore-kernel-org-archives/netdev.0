From: Suresh Reddy <suresh.reddy@broadcom.com>
Subject: [PATCH net] be2net: Add DEVSEC privilege to SET_HSW_CONFIG command.
Date: Tue,  6 Dec 2016 00:33:50 -0500
Message-ID: <20161206053350.23203-1-suresh.reddy@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org, venkatkumar.duvvuru@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp02.broadcom.com ([192.19.219.146]:36606 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbcLFFkl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 00:40:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <venkatkumar.duvvuru@broadcom.com>

OPCODE_COMMON_GET_FN_PRIVILEGES is returning only DEVSEC
privilege (Unrestricted Administrative Privilege) for Lancer NIC functions.
So, driver is failing SET_HSW_CONFIG command, as DEVSEC privilege was not
set in the privilege bitmap. This patch fixes the problem by setting DEVSEC
privilege in SET_HSW_CONFIG’s privilege bitmap.

Signed-off-by: Venkat Duvvuru <venkatkumar.duvvuru@broadcom.com>
Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 1fb5d72..0e74529 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -90,7 +90,8 @@ static struct be_cmd_priv_map cmd_priv_map[] = {
 	{
 		OPCODE_COMMON_SET_HSW_CONFIG,
 		CMD_SUBSYSTEM_COMMON,
-		BE_PRIV_DEVCFG | BE_PRIV_VHADM
+		BE_PRIV_DEVCFG | BE_PRIV_VHADM |
+		BE_PRIV_DEVSEC
 	},
 	{
 		OPCODE_COMMON_GET_EXT_FAT_CAPABILITIES,
-- 
2.10.1
