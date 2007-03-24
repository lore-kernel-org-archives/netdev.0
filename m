From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv4] fib: Fix out of bound access of fib_props[]
Date: Sat, 24 Mar 2007 16:34:36 +0100
Message-ID: <20070324153435.GE521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38488 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932114AbXCXPeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Mar 2007 11:34:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes a typo which caused fib_props[] to have the wrong size
and makes sure the value used to index the array which is
provided by userspace via netlink is checked to avoid out of
bound access.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.orig/net/ipv4/fib_frontend.c	2007-03-24 15:56:17.000000000 +0100
+++ net-2.6/net/ipv4/fib_frontend.c	2007-03-24 15:57:16.000000000 +0100
@@ -493,6 +493,11 @@ static int rtm_to_fib_config(struct sk_b
 	cfg->fc_nlinfo.pid = NETLINK_CB(skb).pid;
 	cfg->fc_nlinfo.nlh = nlh;
 
+	if (cfg->fc_type > RTN_MAX) {
+		err = -EINVAL;
+		goto errout;
+	}
+
 	nlmsg_for_each_attr(attr, nlh, sizeof(struct rtmsg), remaining) {
 		switch (attr->nla_type) {
 		case RTA_DST:
Index: net-2.6/net/ipv4/fib_semantics.c
===================================================================
--- net-2.6.orig/net/ipv4/fib_semantics.c	2007-03-24 15:57:42.000000000 +0100
+++ net-2.6/net/ipv4/fib_semantics.c	2007-03-24 15:58:14.000000000 +0100
@@ -89,7 +89,7 @@ static const struct
 {
 	int	error;
 	u8	scope;
-} fib_props[RTA_MAX + 1] = {
+} fib_props[RTN_MAX + 1] = {
 	{
 		.error	= 0,
 		.scope	= RT_SCOPE_NOWHERE,
