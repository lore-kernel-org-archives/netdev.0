From: igorm@etf.rs
Subject: [PATCH net-next] net: ipv6: proc: Fix error handling
Date: Fri, 16 Dec 2011 13:05:39 +0100
Message-ID: <1324037139-3626-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:34373 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499Ab1LPMFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 07:05:45 -0500
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Fix error handling in case making of dir dev_snmp6 failes

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 net/ipv6/proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index fdeb6d0..6df9035 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -307,10 +307,10 @@ static int __net_init ipv6_proc_init_net(struct net *net)
 		goto proc_dev_snmp6_fail;
 	return 0;
 
+proc_dev_snmp6_fail:
+	proc_net_remove(net, "snmp6");
 proc_snmp6_fail:
 	proc_net_remove(net, "sockstat6");
-proc_dev_snmp6_fail:
-	proc_net_remove(net, "dev_snmp6");
 	return -ENOMEM;
 }
 
-- 
1.7.5.4
