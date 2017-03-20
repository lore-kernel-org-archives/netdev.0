From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/22] ipvs: Document sysctl sync_qlen_max and sync_sock_size
Date: Mon, 20 Mar 2017 11:08:46 +0100
Message-ID: <1490004530-9128-19-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52098 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754071AbdCTKJq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:46 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 1EBD952339
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 052F2DA7E9
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DD477DA804
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:14 +0100 (CET)
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>

Document sysctl sync_qlen_max and sync_sock_size based on
commit 1c003b1580e2 ("ipvs: wakeup master thread").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 Documentation/networking/ipvs-sysctl.txt | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 7acaaa65451e..159d70b6dff3 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -217,6 +217,20 @@ sync_retries - INTEGER
 	to protect against loss of sync messages. The range of the
 	sync_retries is from 0 to 3.
 
+sync_qlen_max - UNSIGNED LONG
+
+	Hard limit for queued sync messages that are not sent yet. It
+	defaults to 1/32 of the memory pages but actually represents
+	number of messages. It will protect us from allocating large
+	parts of memory when the sending rate is lower than the queuing
+	rate.
+
+sync_sock_size - INTEGER
+	default 0
+
+	Configuration of SNDBUF (master) or RCVBUF (slave) socket limit.
+	Default value is 0 (preserve system defaults).
+
 snat_reroute - BOOLEAN
 	0 - disabled
 	not 0 - enabled (default)
-- 
2.1.4
