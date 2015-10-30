From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V19 1/3] openvswitch: 802.1ad uapi changes.
Date: Fri, 30 Oct 2015 13:08:20 -0400
Message-ID: <1446224902-21246-2-git-send-email-thomasfherbert@gmail.com>
References: <1446224902-21246-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:33060 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160AbbJ3RIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 13:08:45 -0400
Received: by ykft191 with SMTP id t191so82101019ykf.0
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 10:08:45 -0700 (PDT)
In-Reply-To: <1446224902-21246-1-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

openvswitch: Add support for 8021.AD

Change the description of the VLAN tpid field.

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
---
 include/uapi/linux/openvswitch.h | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 28ccedd..2e7339d 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -587,13 +587,13 @@ struct ovs_action_push_mpls {
  * @vlan_tci: Tag control identifier (TCI) to push.  The CFI bit must be set
  * (but it will not be set in the 802.1Q header that is pushed).
  *
- * The @vlan_tpid value is typically %ETH_P_8021Q.  The only acceptable TPID
- * values are those that the kernel module also parses as 802.1Q headers, to
- * prevent %OVS_ACTION_ATTR_PUSH_VLAN followed by %OVS_ACTION_ATTR_POP_VLAN
- * from having surprising results.
+ * The @vlan_tpid value is typically %ETH_P_8021Q or %ETH_P_8021AD.
+ * The only acceptable TPID values are those that the kernel module also parses
+ * as 802.1Q or 802.1AD headers, to prevent %OVS_ACTION_ATTR_PUSH_VLAN followed
+ * by %OVS_ACTION_ATTR_POP_VLAN from having surprising results.
  */
 struct ovs_action_push_vlan {
-	__be16 vlan_tpid;	/* 802.1Q TPID. */
+	__be16 vlan_tpid;	/* 802.1Q or 802.1ad TPID. */
 	__be16 vlan_tci;	/* 802.1Q TCI (VLAN ID and priority). */
 };
 
@@ -661,9 +661,10 @@ enum ovs_ct_attr {
  * is copied from the value to the packet header field, rest of the bits are
  * left unchanged.  The non-masked value bits must be passed in as zeroes.
  * Masking is not supported for the %OVS_KEY_ATTR_TUNNEL attribute.
- * @OVS_ACTION_ATTR_PUSH_VLAN: Push a new outermost 802.1Q header onto the
- * packet.
- * @OVS_ACTION_ATTR_POP_VLAN: Pop the outermost 802.1Q header off the packet.
+ * @OVS_ACTION_ATTR_PUSH_VLAN: Push a new outermost 802.1Q or 802.1ad header
+ * onto the packet.
+ * @OVS_ACTION_ATTR_POP_VLAN: Pop the outermost 802.1Q or 802.1ad header
+ * from the packet.
  * @OVS_ACTION_ATTR_SAMPLE: Probabilitically executes actions, as specified in
  * the nested %OVS_SAMPLE_ATTR_* attributes.
  * @OVS_ACTION_ATTR_PUSH_MPLS: Push a new MPLS label stack entry onto the
-- 
2.4.3
