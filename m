From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net 2/4] openvswitch: Clarify conntrack COMMIT behaviour
Date: Mon, 19 Oct 2015 19:18:58 -0700
Message-ID: <1445307540-6786-2-git-send-email-joestringer@nicira.com>
References: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
Cc: tgraf@suug.ch, jrajahalme@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33883 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbbJTCTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 22:19:09 -0400
Received: by padhk11 with SMTP id hk11so4926135pad.1
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 19:19:09 -0700 (PDT)
In-Reply-To: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The presence of this attribute does not modify the ct_state for the
current packet, only future packets. Make this more clear in the header
definition.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v3: First post.
---
 include/uapi/linux/openvswitch.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 036f73bc54cd..e663627a8ef3 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -620,7 +620,8 @@ struct ovs_action_hash {
  * enum ovs_ct_attr - Attributes for %OVS_ACTION_ATTR_CT action.
  * @OVS_CT_ATTR_COMMIT: If present, commits the connection to the conntrack
  * table. This allows future packets for the same connection to be identified
- * as 'established' or 'related'.
+ * as 'established' or 'related'. The flow key for the current packet will
+ * retain the pre-commit connection state.
  * @OVS_CT_ATTR_ZONE: u16 connection tracking zone.
  * @OVS_CT_ATTR_MARK: u32 value followed by u32 mask. For each bit set in the
  * mask, the corresponding bit in the value is copied to the connection
-- 
2.1.4
