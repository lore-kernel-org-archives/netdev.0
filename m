From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 06/19] net core: Remove unneded creation of an empty  net/core sysctl directory
Date: Thu, 19 Apr 2012 16:25:13 -0700
Message-ID: <m1fwbzgv8m.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:56012 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755881Ab2DSXVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:21:12 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On the next line we register the net_core_table in net/core which
creates the directory and ensures it exists.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/sysctl_net_core.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index dfe2885..4a9472d 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -254,9 +254,6 @@ static __net_initdata struct pernet_operations sysctl_core_ops = {
 
 static __init int sysctl_core_init(void)
 {
-	static struct ctl_table empty[1];
-
-	kmemleak_not_leak(register_net_sysctl_table(&init_net, net_core_path, empty));
 	register_net_sysctl(&init_net, "net/core", net_core_table);
 	return register_pernet_subsys(&sysctl_core_ops);
 }
-- 
1.7.2.5
