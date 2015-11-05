From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-dev V20 1/3] openvswitch: 802.1ad uapi changes.
Date: Thu,  5 Nov 2015 14:34:03 -0500
Message-ID: <1446752045-5227-2-git-send-email-thomasfherbert@gmail.com>
References: <1446752045-5227-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33303 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924AbbKETeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 14:34:22 -0500
Received: by qkas77 with SMTP id s77so33377879qka.0
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2015 11:34:21 -0800 (PST)
In-Reply-To: <1446752045-5227-1-git-send-email-thomasfherbert@gmail.com>
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
