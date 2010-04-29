From: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Subject: avoid compiler warning when !CONFIG_SYSCTL in netfilter dccp
Date: Thu, 29 Apr 2010 11:25:26 +0200
Message-ID: <1272533126.16112.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-7ivMFib+bPmLq8qexJFH"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:41126
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759176Ab0D3SPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:15:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7ivMFib+bPmLq8qexJFH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit

The attached trivial patch (generated against davem/net-next-2.6 as of
this morning) avoids this compiler warning:
../src/process-manager/linux/net/netfilter/nf_conntrack_proto_dccp.c: In
function ‘dccp_net_exit’:
../src/process-manager/linux/net/netfilter/nf_conntrack_proto_dccp.c:845: error: unused variable ‘dn’

Mathieu

--=-7ivMFib+bPmLq8qexJFH
Content-Disposition: attachment; filename="nf-dccp-sysctl.patch"
Content-Type: text/x-patch; name="nf-dccp-sysctl.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 5292560..cd078df 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -842,8 +842,8 @@ static __net_init int dccp_net_init(struct net *net)
 
 static __net_exit void dccp_net_exit(struct net *net)
 {
-	struct dccp_net *dn = dccp_pernet(net);
 #ifdef CONFIG_SYSCTL
+	struct dccp_net *dn = dccp_pernet(net);
 	unregister_net_sysctl_table(dn->sysctl_header);
 	kfree(dn->sysctl_table);
 #endif

--=-7ivMFib+bPmLq8qexJFH--

