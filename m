From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: [PATCH]: invalid unregister sysctl table for conntrack
Date: Wed, 09 Jun 2004 23:04:44 +0900 (JST)
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <200406091404.XAA23742@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Wed_Jun__9_23:04:44_2004_590)--"
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

----Next_Part(Wed_Jun__9_23:04:44_2004_590)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Hi,

These patches fix the bug that access null pointer
when failed to register sysctl table for ip_conntrack.

Regards,

-----------------------------------------------------------------
Yasuyuki KOZAKAI @ USAGI Project <yasuyuki.kozakai@toshiba.co.jp>


----Next_Part(Wed_Jun__9_23:04:44_2004_590)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="conntrack-sysctl-2.4.patch"

--- linux-2.4.27-pre5/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-02-18 22:36:32.000000000 +0900
+++ linux-2.4.27-pre5-fixed/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-06-09 23:00:04.454479720 +0900
@@ -377,7 +377,8 @@
 	ip_ct_sysctl_header = register_sysctl_table(ip_ct_net_table, 0);
 	if (ip_ct_sysctl_header == NULL) {
 		printk("ip_conntrack: can't register to sysctl.\n");
-		goto cleanup;
+		ret = -ENOMEM;
+		goto cleanup_localinops;
 	}
 #endif
 
@@ -386,6 +387,7 @@
  cleanup:
 #ifdef CONFIG_SYSCTL
  	unregister_sysctl_table(ip_ct_sysctl_header);
+ cleanup_localinops:
 #endif
 	nf_unregister_hook(&ip_conntrack_local_in_ops);
  cleanup_inoutandlocalops:

----Next_Part(Wed_Jun__9_23:04:44_2004_590)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="conntrack-sysctl-2.6.patch"

--- linux-2.6.7-rc3/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-06-09 21:00:34.000000000 +0900
+++ linux-2.6.7-rc3-fixed/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-06-09 22:58:28.765026728 +0900
@@ -540,7 +540,8 @@
 	ip_ct_sysctl_header = register_sysctl_table(ip_ct_net_table, 0);
 	if (ip_ct_sysctl_header == NULL) {
 		printk("ip_conntrack: can't register to sysctl.\n");
-		goto cleanup;
+		ret = -ENOMEM;
+		goto cleanup_localinops;
 	}
 #endif
 
@@ -549,6 +550,7 @@
  cleanup:
 #ifdef CONFIG_SYSCTL
  	unregister_sysctl_table(ip_ct_sysctl_header);
+ cleanup_localinops:
 #endif
 	nf_unregister_hook(&ip_conntrack_local_in_ops);
  cleanup_inoutandlocalops:

----Next_Part(Wed_Jun__9_23:04:44_2004_590)----
