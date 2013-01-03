From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: Tree for Jan 2 (netfilter)
Date: Thu, 3 Jan 2013 03:30:01 +0100
Message-ID: <20130103023001.GA13254@1984>
References: <20130102151216.b81cd4d4bf54fc8d1f5d9b27@canb.auug.org.au>
 <50E47EEF.8090005@infradead.org>
 <20130103013559.GA2323@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PEIAKu/WMn1b1Hv9"
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130103013559.GA2323@1984>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jan 03, 2013 at 02:35:59AM +0100, Pablo Neira Ayuso wrote:
> > when NF_CONNTRACK is not enabled (build was on i386):
> > 
> >   CC [M]  net/netfilter/xt_CT.o
> > In file included from net/netfilter/xt_CT.c:16:0:
> > include/net/netfilter/nf_conntrack.h:77:22: error: field 'ct_general' has incomplete type
> > include/net/netfilter/nf_conntrack.h: In function 'nf_ct_get':
> > include/net/netfilter/nf_conntrack.h:157:30: error: 'const struct sk_buff' has no member named 'nfct'
> > include/net/netfilter/nf_conntrack.h: In function 'nf_ct_put':
> > include/net/netfilter/nf_conntrack.h:164:2: error: implicit declaration of function 'nf_conntrack_put' [-Werror=implicit-function-declaration]
> > net/netfilter/xt_CT.c: In function 'xt_ct_target_v0':
> > net/netfilter/xt_CT.c:30:9: error: 'struct sk_buff' has no member named 'nfct'
> > net/netfilter/xt_CT.c:34:5: error: 'struct sk_buff' has no member named 'nfct'
> > net/netfilter/xt_CT.c: In function 'xt_ct_target_v1':
> > net/netfilter/xt_CT.c:47:9: error: 'struct sk_buff' has no member named 'nfct'
> > net/netfilter/xt_CT.c:51:5: error: 'struct sk_buff' has no member named 'nfct'
> > net/netfilter/xt_CT.c: In function 'xt_ct_tg_check_v0':
> > net/netfilter/xt_CT.c:155:15: error: 'struct net' has no member named 'ct'
> > net/netfilter/xt_CT.c: In function 'xt_ct_tg_check_v1':
> > net/netfilter/xt_CT.c:299:15: error: 'struct net' has no member named 'ct'
> > net/netfilter/xt_CT.c: In function 'notrack_tg':
> > net/netfilter/xt_CT.c:392:9: error: 'struct sk_buff' has no member named 'nfct'
> > net/netfilter/xt_CT.c:395:5: error: 'struct sk_buff' has no member named 'nfct'
> > net/netfilter/xt_CT.c:397:2: error: implicit declaration of function 'nf_conntrack_get' [-Werror=implicit-function-declaration]
> > net/netfilter/xt_CT.c:397:22: error: 'struct sk_buff' has no member named 'nfct'
> > cc1: some warnings being treated as errors
> > make[3]: *** [net/netfilter/xt_CT.o] Error 1
> 
> Sorry, I cannot reproduce the selection ...

Caught it. Patch attached, thanks for the report.

--PEIAKu/WMn1b1Hv9
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-fix-missing-dependencies-for-the-NOTRACK-t.patch"

>From b8198d1ee451c00c2fd660202ad68580c35e1dd8 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 3 Jan 2013 03:22:36 +0100
Subject: [PATCH] netfilter: fix missing dependencies for the NOTRACK target

warning: (NETFILTER_XT_TARGET_NOTRACK) selects NETFILTER_XT_TARGET_CT which has unmet direct
+dependencies (NET && INET && NETFILTER && NETFILTER_XTABLES && NF_CONNTRACK && (IP_NF_RAW ||
+IP6_NF_RAW) && NETFILTER_ADVANCED)

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 390f96c..49e96df 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -682,6 +682,9 @@ config NETFILTER_XT_TARGET_NFQUEUE
 
 config NETFILTER_XT_TARGET_NOTRACK
 	tristate  '"NOTRACK" target support (DEPRECATED)'
+	depends on NF_CONNTRACK
+	depends on IP_NF_RAW || IP6_NF_RAW
+	depends on NETFILTER_ADVANCED
 	select NETFILTER_XT_TARGET_CT
 
 config NETFILTER_XT_TARGET_RATEEST
-- 
1.7.10.4


--PEIAKu/WMn1b1Hv9--
