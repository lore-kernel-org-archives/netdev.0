From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PATCH] Exporting IPv6 statistics via netlink.
Date: Thu, 19 Apr 2007 21:04:54 +0900 (JST)
Message-ID: <20070419.210454.79003206.yoshfuji@linux-ipv6.org>
References: <20070419.154209.131781981.yoshfuji@linux-ipv6.org>
	<20070419084412.GD521@postel.suug.ch>
	<20070419.175855.130993987.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: tgraf@suug.ch, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43680 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993252AbXDSMDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 08:03:49 -0400
In-Reply-To: <20070419.175855.130993987.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070419.175855.130993987.yoshfuji@linux-ipv6.org> (at Thu, 19 Apr 2007 17:58:55 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20070419084412.GD521@postel.suug.ch> (at Thu, 19 Apr 2007 10:44:12 +0200), Thomas Graf <tgraf@suug.ch> says:
> 
> > * YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> 2007-04-19 15:42
> > > 
> > > Please consider pulling following changesets for supporting exporting
> > > stats information via netlink, on top of net-2.6.22.
> > 
> > The netlink bits are perfectly fine, why the dependency on proc fs?
> 
> I'll follow up to eliminate such dependency afterwards.

Here it is.

All changesets are available on the
    net-2.6.22-20070417-stats-20070419
branch at
    <git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>.

---
[IPV6] SNMP: Export statistics via netlink without CONFIG_PROC_FS.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/proc.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 5c3ce1c..c847cef 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -141,6 +141,7 @@ static struct snmp_mib snmp6_udplite6_list[] = {
 	SNMP_MIB_ITEM("UdpLite6OutDatagrams", UDP_MIB_OUTDATAGRAMS),
 	SNMP_MIB_SENTINEL
 };
+#endif	/* CONFIG_PROC_FS */
 
 static unsigned long
 fold_field(void *mib[], int offt)
@@ -155,6 +156,7 @@ fold_field(void *mib[], int offt)
 	return res;
 }
 
+#ifdef CONFIG_PROC_FS
 static inline void
 snmp6_seq_show_item(struct seq_file *seq, void **mib, struct snmp_mib *itemlist)
 {
@@ -206,6 +208,7 @@ static const struct file_operations snmp6_seq_fops = {
 	.llseek	 = seq_lseek,
 	.release = single_release,
 };
+#endif	/* CONFIG_PROC_FS */
 
 static inline void
 __snmp6_fill_stats(u64 *stats, void **mib, int items, int bytes)
@@ -232,6 +235,7 @@ snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype, int bytes)
 	}
 }
 
+#ifdef CONFIG_PROC_FS
 int snmp6_register_dev(struct inet6_dev *idev)
 {
 	struct proc_dir_entry *p;
@@ -309,12 +313,6 @@ int snmp6_unregister_dev(struct inet6_dev *idev)
 	return 0;
 }
 
-void
-snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype, int bytes)
-{
-	memset(stats, 0, sizeof(bytes));
-}
-
 #endif	/* CONFIG_PROC_FS */
 
 int snmp6_alloc_dev(struct inet6_dev *idev)
-- 
1.5.1

