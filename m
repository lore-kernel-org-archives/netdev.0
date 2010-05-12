From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: linux-next: Tree for May 12 (netfilter: xt_TEE)
Date: Wed, 12 May 2010 22:11:35 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1005122210180.11190@obet.zrqbmnf.qr>
References: <20100512164638.75e6e111.sfr@canb.auug.org.au> <20100512085045.483f0e2d.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	sebastian.classen@freenet.ag,
	Randy Dunlap <randy.dunlap@oracle.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100512085045.483f0e2d.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 2010-05-12 17:50, Randy Dunlap wrote:
>On Wed, 12 May 2010 16:46:38 +1000 Stephen Rothwell wrote:
>
>net/built-in.o: In function `tee_tg_route6':
>xt_TEE.c:(.text+0x45ca5): undefined reference to `ip6_route_output'
>net/built-in.o: In function `tee_tg6':
>xt_TEE.c:(.text+0x45d79): undefined reference to `ip6_local_out'

parent cba7a98a474a4f2a9316473734ba76829191a78a (v2.6.34-rc5-1489-gcba7a98)
commit cff884ea0de4bf8729ac33bb5d98ac9d39d09019
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed May 12 22:10:03 2010 +0200

netfilter: xtables: add missing depends for xt_TEE

Aviod these link-time errors when IPV6=m, XT_TEE=y:

net/built-in.o: In function `tee_tg_route6':
xt_TEE.c:(.text+0x45ca5): undefined reference to `ip6_route_output'
net/built-in.o: In function `tee_tg6':
xt_TEE.c:(.text+0x45d79): undefined reference to `ip6_local_out'

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 673a6c8..e223f47 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -505,6 +505,7 @@ config NETFILTER_XT_TARGET_RATEEST
 config NETFILTER_XT_TARGET_TEE
 	tristate '"TEE" - packet cloning to alternate destiantion'
 	depends on NETFILTER_ADVANCED
+	depends on (IPV6 || IPV6=n)
 	---help---
 	This option adds a "TEE" target with which a packet can be cloned and
 	this clone be rerouted to another nexthop.
-- 
# Created with git-export-patch
