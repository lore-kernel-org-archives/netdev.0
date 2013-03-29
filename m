From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH v2 net-next] netlink: fix the warning introduced by netlink API replacement
Date: Fri, 29 Mar 2013 23:09:35 +0800
Message-ID: <1364569775-4419-1-git-send-email-honkiko@gmail.com>
References: <1364402824-32680-1-git-send-email-honkiko@gmail.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	brian.haley@hp.com, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:47589 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861Ab3C2PJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 11:09:50 -0400
Received: by mail-pa0-f48.google.com with SMTP id lj1so381795pab.21
        for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 08:09:50 -0700 (PDT)
In-Reply-To: <1364402824-32680-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/ieee802154/netlink.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 9247252..7e49bbc 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -64,8 +64,8 @@ struct sk_buff *ieee802154_nl_create(int flags, u8 req)
 
 int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group)
 {
-	/* XXX: nlh is right at the start of msg */
-	void *hdr = genlmsg_data(nlmsg_data(msg->data));
+	struct nlmsghdr *nlh = nlmsg_hdr(msg);
+	void *hdr = genlmsg_data(nlmsg_data(nlh));
 
 	if (genlmsg_end(msg, hdr) < 0)
 		goto out;
@@ -97,8 +97,8 @@ struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
 
 int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info)
 {
-	/* XXX: nlh is right at the start of msg */
-	void *hdr = genlmsg_data(nlmsg_data(msg->data));
+	struct nlmsghdr *nlh = nlmsg_hdr(msg);
+	void *hdr = genlmsg_data(nlmsg_data(nlh));
 
 	if (genlmsg_end(msg, hdr) < 0)
 		goto out;
-- 
1.7.10.4
