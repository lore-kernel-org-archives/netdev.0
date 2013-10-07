From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net ipv4: Allow unprivileged users to use most of the per net systctls
Date: Mon, 07 Oct 2013 16:58:43 -0700
Message-ID: <878uy4skek.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:56723 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591Ab3JGX6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 19:58:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Allow unprivileged users to use:
/proc/sys/net/ipv4/icmp_echo_ignore_all
/proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
/proc/sys/net/ipv4/icmp_ignore_bogus_error_response
/proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr
/proc/sys/net/ipv4/icmp_ratelimit
/proc/sys/net/ipv4/icmp_ratemask
/proc/sys/net/ipv4/ping_group_range
/proc/sys/net/ipv4/tcp_ecn
/proc/sys/net/ipv4/ip_local_ports_range

These are occassionally handy and after a quick review I don't see
any problems with unprivileged users using them.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/sysctl_net_ipv4.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index c08f096d46b5..470ea82fca51 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -898,9 +898,9 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 		table[8].data =
 			&net->ipv4.sysctl_local_ports.range;
 
-		/* Don't export sysctls to unprivileged users */
+		/* Don't export dangerous sysctls to unprivileged users */
 		if (net->user_ns != &init_user_ns)
-			table[0].procname = NULL;
+			table[9].procname = NULL;
 	}
 
 	/*
-- 
1.7.5.4
