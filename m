From: Adrian Bunk <bunk@stusta.de>
Subject: [patch] 2.6.11-rc1-mm1: ip_tables.c: ipt_find_target must be EXPORT_SYMBOL'ed
Date: Fri, 14 Jan 2005 18:35:38 +0100
Message-ID: <20050114173538.GB4274@stusta.de>
References: <20050114002352.5a038710.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262035AbVANRfr@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>
Content-Disposition: inline
In-Reply-To: <20050114002352.5a038710.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 14, 2005 at 12:23:52AM -0800, Andrew Morton wrote:
>...
> All 434 patches:
>...
> restore-net-sched-iptc-after-iptables-kmod-cleanup.patch
>   Restore net/sched/ipt.c After iptables Kmod Cleanup
>...

This causes the following error with CONFIG_NET_ACT_IPT=m:

<--  snip  -->

if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.6.11-rc1-mm1; fi
WARNING: /lib/modules/2.6.11-rc1-mm1/kernel/net/sched/ipt.ko needs unknown symbol ipt_find_target

<--  snip  -->


The fix is simple:


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.11-rc1-mm1-modular/net/ipv4/netfilter/ip_tables.c.old	2005-01-14 18:03:18.000000000 +0100
+++ linux-2.6.11-rc1-mm1-modular/net/ipv4/netfilter/ip_tables.c	2005-01-14 18:04:17.000000000 +0100
@@ -488,6 +488,7 @@
 		return NULL;
 	return target;
 }
+EXPORT_SYMBOL(ipt_find_target);
 
 static int match_revfn(const char *name, u8 revision, int *bestp)
 {
