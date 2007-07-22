From: Thomas Graf <tgraf@suug.ch>
Subject: [RTNETLINK]: Fix warning if !CONFIG_KMOD
Date: Sun, 22 Jul 2007 12:37:42 +0200
Message-ID: <20070722103742.GJ3651@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53000 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753576AbXGVKhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2007 06:37:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

replay label is unused otherwise.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/core/rtnetlink.c
===================================================================
--- net-2.6.orig/net/core/rtnetlink.c	2007-07-22 11:41:46.000000000 +0200
+++ net-2.6/net/core/rtnetlink.c	2007-07-22 12:04:27.000000000 +0200
@@ -952,7 +952,9 @@ static int rtnl_newlink(struct sk_buff *
 	struct nlattr *linkinfo[IFLA_INFO_MAX+1];
 	int err;
 
+#ifdef CONFIG_KMOD
 replay:
+#endif
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
 	if (err < 0)
 		return err;
