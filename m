From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/22] ipvs: fix sync_threshold description and add sync_refresh_period, sync_retries
Date: Mon, 20 Mar 2017 11:08:45 +0100
Message-ID: <1490004530-9128-18-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52080 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754039AbdCTKJl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:41 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 1EDC25233A
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 07941DA807
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 255B8DA871
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:14 +0100 (CET)
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>

Fix sync_threshold description which should have two values. Also add
sync_refresh_period and sync_retries based on commit 749c42b620a9
("ipvs: reduce sync rate with time thresholds").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 Documentation/networking/ipvs-sysctl.txt | 40 +++++++++++++++++++++++++-------
 1 file changed, 31 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index e6b1c025fdd8..7acaaa65451e 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -185,15 +185,37 @@ secure_tcp - INTEGER
         The value definition is the same as that of drop_entry and
         drop_packet.
 
-sync_threshold - INTEGER
-        default 3
-
-        It sets synchronization threshold, which is the minimum number
-        of incoming packets that a connection needs to receive before
-        the connection will be synchronized. A connection will be
-        synchronized, every time the number of its incoming packets
-        modulus 50 equals the threshold. The range of the threshold is
-        from 0 to 49.
+sync_threshold - vector of 2 INTEGERs: sync_threshold, sync_period
+	default 3 50
+
+	It sets synchronization threshold, which is the minimum number
+	of incoming packets that a connection needs to receive before
+	the connection will be synchronized. A connection will be
+	synchronized, every time the number of its incoming packets
+	modulus sync_period equals the threshold. The range of the
+	threshold is from 0 to sync_period.
+
+	When sync_period and sync_refresh_period are 0, send sync only
+	for state changes or only once when pkts matches sync_threshold
+
+sync_refresh_period - UNSIGNED INTEGER
+	default 0
+
+	In seconds, difference in reported connection timer that triggers
+	new sync message. It can be used to avoid sync messages for the
+	specified period (or half of the connection timeout if it is lower)
+	if connection state is not changed since last sync.
+
+	This is useful for normal connections with high traffic to reduce
+	sync rate. Additionally, retry sync_retries times with period of
+	sync_refresh_period/8.
+
+sync_retries - INTEGER
+	default 0
+
+	Defines sync retries with period of sync_refresh_period/8. Useful
+	to protect against loss of sync messages. The range of the
+	sync_retries is from 0 to 3.
 
 snat_reroute - BOOLEAN
 	0 - disabled
-- 
2.1.4
