From: Thomas Graf <tgraf@suug.ch>
Subject: [NETFILTER] nfnetlink: netlink_run_queue() already checks for NLM_F_REQUEST
Date: Wed, 21 Mar 2007 13:33:04 +0100
Message-ID: <20070321123304.GV521@postel.suug.ch>
References: <20070321001810.616784269@lsx.localdomain> <20070321001900.748961655@lsx.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:47347 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752687AbXCUMco (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 08:32:44 -0400
Content-Disposition: inline
In-Reply-To: <20070321001900.748961655@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick has made use of netlink_run_queue() in nfnetlink while my patches
have been waiting for net-2.6.22 to open. So this check for NLM_F_REQUEST
can go as well.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/netfilter/nfnetlink.c
===================================================================
--- net-2.6.22.orig/net/netfilter/nfnetlink.c	2007-03-21 13:27:48.000000000 +0100
+++ net-2.6.22/net/netfilter/nfnetlink.c	2007-03-21 13:28:11.000000000 +0100
@@ -207,10 +207,6 @@ static int nfnetlink_rcv_msg(struct sk_b
 		return -1;
 	}
 
-	/* Only requests are handled by kernel now. */
-	if (!(nlh->nlmsg_flags & NLM_F_REQUEST))
-		return 0;
-
 	/* All the messages must at least contain nfgenmsg */
 	if (nlh->nlmsg_len < NLMSG_SPACE(sizeof(struct nfgenmsg)))
 		return 0;
