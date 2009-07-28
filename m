From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [Resent][PATCH 1/1] inet6: functions shadow global variable
Date: Tue, 28 Jul 2009 21:48:07 +0200
Message-ID: <20090728194807.GB6277@gerrit.erg.abdn.ac.uk>
References: <1248028721-24244-1-git-send-email-gerrit@erg.abdn.ac.uk> <1248028721-24244-2-git-send-email-gerrit@erg.abdn.ac.uk> <1248028721-24244-3-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:38760 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750695AbZG1TsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2009 15:48:15 -0400
Content-Disposition: inline
In-Reply-To: <1248028721-24244-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was no further response on the RFC, I am resending it as a fix.

>>>>>>>>>>>>>>>>>>>>>>>>> Patch v1 (resent) <<<<<<<<<<<<<<<<<<<<<<<<
inet6: local functions shadow global pointer

This renames away a variable clash:
 * ipv6_table[] is declared as a static global table;
 * ipv6_sysctl_net_init() uses ipv6_table to refer/destroy dynamic memory;
 * ipv6_sysctl_net_exit() also uses ipv6_table for the same purpose;
 * both the two last functions call kfree() on ipv6_table.

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
 
