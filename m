From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [RFC][PATCH 2/2] inet6: sysctl pointers shadow global pointer
Date: Sun, 19 Jul 2009 20:38:41 +0200
Message-ID: <1248028721-24244-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <cases_of_shadowing_other_variables>
 <1248028721-24244-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1248028721-24244-2-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54994 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751376AbZGSSiu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 14:38:50 -0400
In-Reply-To: <1248028721-24244-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv6/sysctl_net_ipv6.c:64:19:  warning: symbol 'ipv6_table' shadows an earlier one
net/ipv6/sysctl_net_ipv6.c:107:19: warning: symbol 'ipv6_table' shadows an earlier one
net/ipv6/sysctl_net_ipv6.c:43:18:  originally declared here

The only place where 'ipv6_table' is not shadowed is in ipv6_sysctl_register().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv6/sysctl_net_ipv6.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -40,7 +40,7 @@ static ctl_table ipv6_table_template[] =
 	{ .ctl_name = 0 }
 };
 
-static ctl_table ipv6_table[] = {
+static ctl_table ipv6_rotable[] = {
 	{
 		.ctl_name	= NET_IPV6_MLD_MAX_MSF,
 		.procname	= "mld_max_msf",
@@ -130,7 +130,7 @@ int ipv6_sysctl_register(void)
 {
 	int err = -ENOMEM;
 
-	ip6_header = register_net_sysctl_rotable(net_ipv6_ctl_path, ipv6_table);
+	ip6_header = register_net_sysctl_rotable(net_ipv6_ctl_path, ipv6_rotable);
 	if (ip6_header == NULL)
 		goto out;
 
