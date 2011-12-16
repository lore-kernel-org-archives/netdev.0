From: igorm@etf.rs
Subject: [PATCH 08/10 net-next] net:ipv4:af_inet: Init proc fs before ip_init
Date: Fri, 16 Dec 2011 16:26:01 +0100
Message-ID: <1324049163-11207-9-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1324049163-11207-1-git-send-email-igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:53871 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760027Ab1LPP00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 10:26:26 -0500
In-Reply-To: <1324049163-11207-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Moved ipv4_proc_init() before ip_init().
Did that, so the proc fs for ipv4 would be initialised
before we initialise devinet. If I didn't do that,
per device proc files couldn't be created

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 net/ipv4/af_inet.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f7b5670..7384a20 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1695,6 +1695,11 @@ static int __init inet_init(void)
 
 	for (q = inetsw_array; q < &inetsw_array[INETSW_ARRAY_LEN]; ++q)
 		inet_register_protosw(q);
+		
+	/*
+	 * Init proc fs
+	 */
+	ipv4_proc_init();
 
 	/*
 	 *	Set the ARP module up
@@ -1742,8 +1747,6 @@ static int __init inet_init(void)
 	if (init_ipv4_mibs())
 		printk(KERN_CRIT "inet_init: Cannot init ipv4 mibs\n");
 
-	ipv4_proc_init();
-
 	ipfrag_init();
 
 	dev_add_pack(&ip_packet_type);
-- 
1.7.5.4
