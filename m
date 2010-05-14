From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] netfilter: xt_TEE depends on NF_CONNTRACK
Date: Fri, 14 May 2010 10:12:18 -0700
Message-ID: <20100514101218.16cdb0ad.randy.dunlap@oracle.com>
References: <20100514161407.740da901.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>,
	netfilter-devel@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100514161407.740da901.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix xt_TEE build for the case of NF_CONNTRACK=m and
NETFILTER_XT_TARGET_TEE=y:

xt_TEE.c:(.text+0x6df5c): undefined reference to `nf_conntrack_untracked'
4x

Built with all 4 m/y combinations.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc:	Patrick McHardy <kaber@trash.net>
Cc:	Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-next-20100514.orig/net/netfilter/Kconfig
+++ linux-next-20100514/net/netfilter/Kconfig
@@ -506,6 +506,7 @@ config NETFILTER_XT_TARGET_TEE
 	tristate '"TEE" - packet cloning to alternate destiantion'
 	depends on NETFILTER_ADVANCED
 	depends on (IPV6 || IPV6=n)
+	depends on !NF_CONNTRACK || NF_CONNTRACK
 	---help---
 	This option adds a "TEE" target with which a packet can be cloned and
 	this clone be rerouted to another nexthop.
