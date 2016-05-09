From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/36] netfilter: nf_ct_helper: disable automatic helper assignment
Date: Mon,  9 May 2016 20:46:29 +0200
Message-ID: <1462819614-5402-12-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45685 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487AbcEISrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:15 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 45858E8E84
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:14 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 327A813470C
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:14 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2678613470C
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:12 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Four years ago we introduced a new sysctl knob to disable automatic
helper assignment in 72110dfaa907 ("netfilter: nf_ct_helper: disable
automatic helper assignment"). This knob kept this behaviour enabled by
default to remain conservative.

This measure was introduced to provide a secure way to configure
iptables and connection tracking helpers through explicit rules.

Give the time we have waited for this, let's turn off this by default
now, worse case users still have a chance to recover the former
behaviour by explicitly enabling this back through sysctl.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_helper.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 3b40ec5..498bf74 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -38,10 +38,10 @@ unsigned int nf_ct_helper_hsize __read_mostly;
 EXPORT_SYMBOL_GPL(nf_ct_helper_hsize);
 static unsigned int nf_ct_helper_count __read_mostly;
 
-static bool nf_ct_auto_assign_helper __read_mostly = true;
+static bool nf_ct_auto_assign_helper __read_mostly = false;
 module_param_named(nf_conntrack_helper, nf_ct_auto_assign_helper, bool, 0644);
 MODULE_PARM_DESC(nf_conntrack_helper,
-		 "Enable automatic conntrack helper assignment (default 1)");
+		 "Enable automatic conntrack helper assignment (default 0)");
 
 #ifdef CONFIG_SYSCTL
 static struct ctl_table helper_sysctl_table[] = {
-- 
2.1.4
