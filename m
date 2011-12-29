From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: Tree for Dec 28 (nfnetlink)
Date: Thu, 29 Dec 2011 02:03:30 +0100
Message-ID: <20111229010330.GA2663@1984>
References: <20111228201806.d6de27fa2dbd9e3a3b7a2603@canb.auug.org.au>
 <4EFB87CC.6020105@xenotime.net>
 <20111228.153304.1267926241298522965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Cc: rdunlap@xenotime.net, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111228.153304.1267926241298522965.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Dec 28, 2011 at 03:33:04PM -0500, David Miller wrote:
> From: Randy Dunlap <rdunlap@xenotime.net>
> Date: Wed, 28 Dec 2011 13:19:08 -0800
> 
> > On 12/28/2011 01:18 AM, Stephen Rothwell wrote:
> >> Hi all,
> >> 
> >> I got bored :-(  I also hate tree wide, flag day changes :-(
> >> 
> >> Changes since 20111222:
> > 
> > 
> > 
> > warning: (NETFILTER_XT_MATCH_NFACCT) selects NETFILTER_NETLINK_ACCT which has unmet direct dependencies (NET && INET && NETFILTER && NETFILTER_ADVANCED)
> > 
> > and then
> > 
> > ERROR: "nfnetlink_subsys_unregister" [net/netfilter/nfnetlink_acct.ko] undefined!
> > ERROR: "nfnetlink_subsys_register" [net/netfilter/nfnetlink_acct.ko] undefined!
> > 
> > 
> > Full randconfig file is attached.
> 
> Pablo please fix this, thanks.

Please, apply the following patch.

--fUYQa+Pmc3FrFX/N
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-Kconfig-fix-unmet-xt_nfacct-dependencies.patch"

>From 3e52c20b633f9c829eaa9fe693a0cbef10ac4d02 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 29 Dec 2011 01:50:25 +0100
Subject: [PATCH] netfilter: Kconfig: fix unmet xt_nfacct dependencies

warning: (NETFILTER_XT_MATCH_NFACCT) selects NETFILTER_NETLINK_ACCT which has
nmet direct dependencies (NET && INET && NETFILTER && NETFILTER_ADVANCED)

and then

ERROR: "nfnetlink_subsys_unregister" [net/netfilter/nfnetlink_acct.ko]
ndefined!
ERROR: "nfnetlink_subsys_register" [net/netfilter/nfnetlink_acct.ko]
+undefined!

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index f6275a0..f8ac4ef 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -908,7 +908,7 @@ config NETFILTER_XT_MATCH_MULTIPORT
 
 config NETFILTER_XT_MATCH_NFACCT
 	tristate '"nfacct" match support'
-	default m if NETFILTER_ADVANCED=n
+	depends on NETFILTER_ADVANCED
 	select NETFILTER_NETLINK_ACCT
 	help
 	  This option allows you to use the extended accounting through
-- 
1.7.7.3


--fUYQa+Pmc3FrFX/N--
