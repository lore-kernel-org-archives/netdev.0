From: Thomas Graf <tgraf@suug.ch>
Subject: [RTNL]: Add missing link netlink attribute policy definitions
Date: Wed, 20 Feb 2008 00:46:06 +0100
Message-ID: <20080219234606.GA3119@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:51362 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763230AbYBTAOs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 19:14:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFLA_LINK is no longer a write-only attribute on the kernel
side and must thus be validated. Same goes for the newly
introduced IFLA_LINKINFO.

Fixes undefined behaviour if either of the attributes are
not well formed.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.26/net/core/rtnetlink.c
===================================================================
--- net-2.6.26.orig/net/core/rtnetlink.c	2008-02-19 20:30:08.000000000 +0100
+++ net-2.6.26/net/core/rtnetlink.c	2008-02-20 00:39:54.000000000 +0100
@@ -693,10 +693,12 @@
 	[IFLA_BROADCAST]	= { .type = NLA_BINARY, .len = MAX_ADDR_LEN },
 	[IFLA_MAP]		= { .len = sizeof(struct rtnl_link_ifmap) },
 	[IFLA_MTU]		= { .type = NLA_U32 },
+	[IFLA_LINK]		= { .type = NLA_U32 },
 	[IFLA_TXQLEN]		= { .type = NLA_U32 },
 	[IFLA_WEIGHT]		= { .type = NLA_U32 },
 	[IFLA_OPERSTATE]	= { .type = NLA_U8 },
 	[IFLA_LINKMODE]		= { .type = NLA_U8 },
+	[IFLA_LINKINFO]		= { .type = NLA_NESTED },
 	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
 };
 
