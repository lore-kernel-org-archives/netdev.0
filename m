From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] net.ipv4.ip_autoconfig sysctl removal
Date: Mon, 5 Jun 2006 10:58:31 -0700
Message-ID: <20060605105831.6a314086@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64474 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751247AbWFER60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 13:58:26 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sysctl net.ipv4.ip_autoconfig is a legacy value that is not used.
Can it finally go in 2.6.18 or do we need to go through the whole 
feature-removal process?

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff --git a/include/net/ip.h b/include/net/ip.h
index 3d2e5ca..ead233c 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -147,7 +147,6 @@ void ip_send_reply(struct sock *sk, stru
 struct ipv4_config
 {
 	int	log_martians;
-	int	autoconfig;
 	int	no_pmtu_disc;
 };
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 6b6c3ad..9d2b81e 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -182,14 +182,6 @@ ctl_table ipv4_table[] = {
 		.strategy	= &ipv4_doint_and_flush_strategy,
 	},
         {
-		.ctl_name	= NET_IPV4_AUTOCONFIG,
-		.procname	= "ip_autoconfig",
-		.data		= &ipv4_config.autoconfig,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
-	},
-        {
 		.ctl_name	= NET_IPV4_NO_PMTU_DISC,
 		.procname	= "ip_no_pmtu_disc",
 		.data		= &ipv4_config.no_pmtu_disc,
