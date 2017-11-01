From: Manish Kurup <kurup.manish@gmail.com>
Subject: [PATCH net-next v5 2/3] nfp flower action: Modified to use VLAN helper functions
Date: Wed,  1 Nov 2017 17:45:32 -0400
Message-ID: <1509572732-17306-1-git-send-email-manish.kurup@verizon.com>
Cc: aring@mojatatu.com, mrv@mojatatu.com, kurup.manish@gmail.com,
        Manish Kurup <manish.kurup@verizon.com>
To: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        oss-drivers@netronome.com, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:55019 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933551AbdKAVpq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 17:45:46 -0400
Received: by mail-qt0-f195.google.com with SMTP id z19so4465256qtg.11
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 14:45:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modified netronome nfp flower action to use VLAN helper functions instead
of accessing the structure directly.

Signed-off-by: Manish Kurup <manish.kurup@verizon.com>
---
 drivers/net/ethernet/netronome/nfp/flower/action.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/action.c b/drivers/net/ethernet/netronome/nfp/flower/action.c
index de64ced..c1c595f 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/action.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/action.c
@@ -58,7 +58,6 @@ nfp_fl_push_vlan(struct nfp_fl_push_vlan *push_vlan,
 		 const struct tc_action *action)
 {
 	size_t act_size = sizeof(struct nfp_fl_push_vlan);
-	struct tcf_vlan *vlan = to_vlan(action);
 	u16 tmp_push_vlan_tci;
 
 	push_vlan->head.jump_id = NFP_FL_ACTION_OPCODE_PUSH_VLAN;
@@ -67,8 +66,8 @@ nfp_fl_push_vlan(struct nfp_fl_push_vlan *push_vlan,
 	push_vlan->vlan_tpid = tcf_vlan_push_proto(action);
 
 	tmp_push_vlan_tci =
-		FIELD_PREP(NFP_FL_PUSH_VLAN_PRIO, vlan->tcfv_push_prio) |
-		FIELD_PREP(NFP_FL_PUSH_VLAN_VID, vlan->tcfv_push_vid) |
+		FIELD_PREP(NFP_FL_PUSH_VLAN_PRIO, tcf_vlan_push_prio(action)) |
+		FIELD_PREP(NFP_FL_PUSH_VLAN_VID, tcf_vlan_push_vid(action)) |
 		NFP_FL_PUSH_VLAN_CFI;
 	push_vlan->vlan_tci = cpu_to_be16(tmp_push_vlan_tci);
 }
-- 
2.7.4
