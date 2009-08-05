From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm] xfrm4: fix build when SYSCTLs are disabled
Date: Tue, 4 Aug 2009 18:54:30 -0700
Message-ID: <20090804185430.fb8e8561.randy.dunlap@oracle.com>
References: <200908042125.n74LP9qY018119@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev <netdev@vger.kernel.org>,
	davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:60878 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933058AbZHEBzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 21:55:11 -0400
In-Reply-To: <200908042125.n74LP9qY018119@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix build errors when SYSCTLs are not enabled:
(.init.text+0x5154): undefined reference to `net_ipv4_ctl_path'
(.init.text+0x5176): undefined reference to `register_net_sysctl_table'
xfrm4_policy.c:(.exit.text+0x573): undefined reference to `unregister_net_sysctl_table

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/ipv4/xfrm4_policy.c |    6 ++++++
 1 file changed, 6 insertions(+)

--- mmotm-2009-0804-1422.orig/net/ipv4/xfrm4_policy.c
+++ mmotm-2009-0804-1422/net/ipv4/xfrm4_policy.c
@@ -264,6 +264,7 @@ static struct xfrm_policy_afinfo xfrm4_p
 	.fill_dst =		xfrm4_fill_dst,
 };
 
+#ifdef CONFIG_SYSCTL
 static struct ctl_table xfrm4_policy_table[] = {
 	{
 		.ctl_name       = CTL_UNNUMBERED,
@@ -277,6 +278,7 @@ static struct ctl_table xfrm4_policy_tab
 };
 
 static struct ctl_table_header *sysctl_hdr;
+#endif
 
 static void __init xfrm4_policy_init(void)
 {
@@ -285,8 +287,10 @@ static void __init xfrm4_policy_init(voi
 
 static void __exit xfrm4_policy_fini(void)
 {
+#ifdef CONFIG_SYSCTL
 	if (sysctl_hdr)
 		unregister_net_sysctl_table(sysctl_hdr);
+#endif
 	xfrm_policy_unregister_afinfo(&xfrm4_policy_afinfo);
 }
 
@@ -305,7 +309,9 @@ void __init xfrm4_init(int rt_max_size)
 	 * and start cleaning when were 1/2 full
 	 */
 	xfrm4_dst_ops.gc_thresh = rt_max_size/2;
+#ifdef CONFIG_SYSCTL
 	sysctl_hdr = register_net_sysctl_table(&init_net, net_ipv4_ctl_path,
 						xfrm4_policy_table);
+#endif
 }
 



---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
