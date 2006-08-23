From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 36/44] [XFRM]: Introduce XFRM_MSG_REPORT.
Date: Thu, 24 Aug 2006 00:02:37 +0900
Message-ID: <11563453672531-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-email-yoshfuji@linux-ipv6.org> <11563453673517-git-send-email-yoshfuji@linux-ipv6.org> <11563453674137-git-send-email-yoshfuji@linux-ipv6.org> <11563453671944-git-send-email-yoshfuji@linux-ipv6.org> <11
 563453671187-git-send-email-yoshfuji@linux-ipv6.org> <11563453672959-git-send-email-yoshfuji@linux-ipv6.org> <1156345367208-git-send-email-yoshfuji@linux-ipv6.org> <11563453673786-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:9865 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964951AbWHWPCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:52 -0400
To: davem@davemloft.net
In-Reply-To: <11563453673786-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

XFRM_MSG_REPORT is a message as notification of state protocol and selector
from kernel to user-space.
Mobile IPv6 will use it when inbound reject is occurred at route optimization
to make user-space know a binding error requirement.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/xfrm.h  |   12 ++++++++++++
 include/net/xfrm.h    |    2 ++
 net/xfrm/xfrm_state.c |   19 +++++++++++++++++++
 net/xfrm/xfrm_user.c  |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 79 insertions(+), 0 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 1d8c1f2..4009f44 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -166,6 +166,10 @@ #define XFRM_MSG_FLUSHPOLICY XFRM_MSG_FL
 #define XFRM_MSG_NEWAE XFRM_MSG_NEWAE
 	XFRM_MSG_GETAE,
 #define XFRM_MSG_GETAE XFRM_MSG_GETAE
+
+	XFRM_MSG_REPORT,
+#define XFRM_MSG_REPORT XFRM_MSG_REPORT
+
 	__XFRM_MSG_MAX
 };
 #define XFRM_MSG_MAX (__XFRM_MSG_MAX - 1)
@@ -325,12 +329,18 @@ struct xfrm_usersa_flush {
 	__u8				proto;
 };
 
+struct xfrm_user_report {
+	__u8				proto;
+	struct xfrm_selector		sel;
+};
+
 #ifndef __KERNEL__
 /* backwards compatibility for userspace */
 #define XFRMGRP_ACQUIRE		1
 #define XFRMGRP_EXPIRE		2
 #define XFRMGRP_SA		4
 #define XFRMGRP_POLICY		8
+#define XFRMGRP_REPORT		0x10
 #endif
 
 enum xfrm_nlgroups {
@@ -346,6 +356,8 @@ #define XFRMNLGRP_SA		XFRMNLGRP_SA
 #define XFRMNLGRP_POLICY	XFRMNLGRP_POLICY
 	XFRMNLGRP_AEVENTS,
 #define XFRMNLGRP_AEVENTS	XFRMNLGRP_AEVENTS
+	XFRMNLGRP_REPORT,
+#define XFRMNLGRP_REPORT	XFRMNLGRP_REPORT
 	__XFRMNLGRP_MAX
 };
 #define XFRMNLGRP_MAX	(__XFRMNLGRP_MAX - 1)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 276884f..00784d9 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -382,6 +382,7 @@ struct xfrm_mgr
 	struct xfrm_policy	*(*compile_policy)(struct sock *sk, int opt, u8 *data, int len, int *dir);
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
 	int			(*notify_policy)(struct xfrm_policy *x, int dir, struct km_event *c);
+	int			(*report)(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
 };
 
 extern int xfrm_register_km(struct xfrm_mgr *km);
@@ -1043,6 +1044,7 @@ extern void xfrm_init_pmtu(struct dst_en
 extern wait_queue_head_t km_waitq;
 extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
 extern void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 pid);
+extern int km_report(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
 
 extern void xfrm_input_init(void);
 extern int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, u32 *spi, u32 *seq);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 3da89c0..a26ef69 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1055,6 +1055,25 @@ void km_policy_expired(struct xfrm_polic
 }
 EXPORT_SYMBOL(km_policy_expired);
 
+int km_report(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr)
+{
+	int err = -EINVAL;
+	int ret;
+	struct xfrm_mgr *km;
+
+	read_lock(&xfrm_km_lock);
+	list_for_each_entry(km, &xfrm_km_list, list) {
+		if (km->report) {
+			ret = km->report(proto, sel, addr);
+			if (!ret)
+				err = ret;
+		}
+	}
+	read_unlock(&xfrm_km_lock);
+	return err;
+}
+EXPORT_SYMBOL(km_report);
+
 int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen)
 {
 	int err;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index ae8dc6b..a4a4dd6 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1489,6 +1489,7 @@ static const int xfrm_msg_min[XFRM_NR_MS
 	[XFRM_MSG_FLUSHPOLICY - XFRM_MSG_BASE] = NLMSG_LENGTH(0),
 	[XFRM_MSG_NEWAE       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_aevent_id),
 	[XFRM_MSG_GETAE       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_aevent_id),
+	[XFRM_MSG_REPORT      - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_report),
 };
 
 #undef XMSGSIZE
@@ -2056,12 +2057,57 @@ static int xfrm_send_policy_notify(struc
 
 }
 
+static int build_report(struct sk_buff *skb, u8 proto,
+			struct xfrm_selector *sel, xfrm_address_t *addr)
+{
+	struct xfrm_user_report *ur;
+	struct nlmsghdr *nlh;
+	unsigned char *b = skb->tail;
+
+	nlh = NLMSG_PUT(skb, 0, 0, XFRM_MSG_REPORT, sizeof(*ur));
+	ur = NLMSG_DATA(nlh);
+	nlh->nlmsg_flags = 0;
+
+	ur->proto = proto;
+	memcpy(&ur->sel, sel, sizeof(ur->sel));
+
+	if (addr)
+		RTA_PUT(skb, XFRMA_COADDR, sizeof(*addr), addr);
+
+	nlh->nlmsg_len = skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static int xfrm_send_report(u8 proto, struct xfrm_selector *sel,
+			    xfrm_address_t *addr)
+{
+	struct sk_buff *skb;
+	size_t len;
+
+	len = NLMSG_ALIGN(NLMSG_LENGTH(sizeof(struct xfrm_user_report)));
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+
+	if (build_report(skb, proto, sel, addr) < 0)
+		BUG();
+
+	NETLINK_CB(skb).dst_group = XFRMNLGRP_REPORT;
+	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_REPORT, GFP_ATOMIC);
+}
+
 static struct xfrm_mgr netlink_mgr = {
 	.id		= "netlink",
 	.notify		= xfrm_send_state_notify,
 	.acquire	= xfrm_send_acquire,
 	.compile_policy	= xfrm_compile_policy,
 	.notify_policy	= xfrm_send_policy_notify,
+	.report		= xfrm_send_report,
 };
 
 static int __init xfrm_user_init(void)
-- 
1.4.0

