From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH] netlink: fix the warning introduced by netlink API replacement
Date: Fri, 29 Mar 2013 21:22:40 +0800
Message-ID: <1364563360-3516-1-git-send-email-honkiko@gmail.com>
References: <1364402824-32680-1-git-send-email-honkiko@gmail.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	brian.haley@hp.com, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:34368 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755443Ab3C2NXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 09:23:03 -0400
Received: by mail-da0-f53.google.com with SMTP id n34so220353dal.40
        for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 06:23:02 -0700 (PDT)
In-Reply-To: <1364402824-32680-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/ieee802154/netlink.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 9247252..91b0363 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -65,7 +65,8 @@ struct sk_buff *ieee802154_nl_create(int flags, u8 req)
 int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group)
 {
 	/* XXX: nlh is right at the start of msg */
-	void *hdr = genlmsg_data(nlmsg_data(msg->data));
+	struct nlmsghdr *nlh = (struct nlmsghdr *)msg->data;
+	void *hdr = genlmsg_data(nlmsg_data(nlh));
 
 	if (genlmsg_end(msg, hdr) < 0)
 		goto out;
@@ -98,7 +99,8 @@ struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
 int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info)
 {
 	/* XXX: nlh is right at the start of msg */
-	void *hdr = genlmsg_data(nlmsg_data(msg->data));
+	struct nlmsghdr *nlh = (struct nlmsghdr *)msg->data;
+	void *hdr = genlmsg_data(nlmsg_data(nlh));
 
 	if (genlmsg_end(msg, hdr) < 0)
 		goto out;
-- 
1.7.10.4
