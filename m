From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH V3 1/1] ipv6: Remove unnecessary test
Date: Wed, 26 Nov 2014 10:25:58 +0800
Message-ID: <1416968758-19641-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Hong Zhiguo <honkiko@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Cong Wang <cwang@twopensource.com>
To: zyjzyj2000@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:62687 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbaKZC0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 21:26:11 -0500
Received: by mail-pd0-f177.google.com with SMTP id ft15so1772078pdb.8
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 18:26:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "init_net" test in function addrconf_exit_net is introduced
in commit 44a6bd29 [Create ipv6 devconf-s for namespaces] to avoid freeing
init_net. In commit c900a800 [ipv6: fix bad free of addrconf_init_net],
function addrconf_init_net will allocate memory for every net regardless of
init_net. In this case, it is unnecessary to make "init_net" test.

CC: Hong Zhiguo <honkiko@gmail.com>
CC: Octavian Purdila <opurdila@ixiacom.com>
CC: Pavel Emelyanov <xemul@openvz.org>
CC: Cong Wang <cwang@twopensource.com>
Suggested-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>

---
 net/ipv6/addrconf.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0169ccf..b8724fc 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5336,10 +5336,8 @@ static void __net_exit addrconf_exit_net(struct net *net)
 	__addrconf_sysctl_unregister(net->ipv6.devconf_dflt);
 	__addrconf_sysctl_unregister(net->ipv6.devconf_all);
 #endif
-	if (!net_eq(net, &init_net)) {
-		kfree(net->ipv6.devconf_dflt);
-		kfree(net->ipv6.devconf_all);
-	}
+	kfree(net->ipv6.devconf_dflt);
+	kfree(net->ipv6.devconf_all);
 }
 
 static struct pernet_operations addrconf_ops = {
-- 
1.9.1
