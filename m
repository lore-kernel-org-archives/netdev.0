From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: XT_MATCH_REALM Kconfig whinge...
Date: Wed, 12 Jan 2011 20:48:13 +0100
Message-ID: <4D2E057D.30707@netfilter.org>
References: <20519.1294859715@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040802060206090200020108"
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20519.1294859715@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040802060206090200020108
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 12/01/11 20:15, Valdis.Kletnieks@vt.edu wrote:
> scripts/kconfig/conf --silentoldconfig Kconfig
> warning: (NETFILTER_XT_MATCH_REALM) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)
> warning: (NETFILTER_XT_MATCH_REALM) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)

Does this fix your problem?

--------------040802060206090200020108
Content-Type: text/x-patch;
 name="realm.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="realm.patch"

netfilter: xt_realm: fix unmet direct dependencies

scripts/kconfig/conf --silentoldconfig Kconfig
warning: (NETFILTER_XT_MATCH_REALM) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)
warning: (NETFILTER_XT_MATCH_REALM) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)

Reported by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 1534f2b..ae56764 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -886,7 +886,8 @@ config NETFILTER_XT_MATCH_RATEEST
 config NETFILTER_XT_MATCH_REALM
 	tristate  '"realm" match support'
 	depends on NETFILTER_ADVANCED
-	select NET_CLS_ROUTE
+	depends on NET_SCHED
+	depends on NET_CLS_ROUTE
 	help
 	  This option adds a `realm' match, which allows you to use the realm
 	  key from the routing subsystem inside iptables.

--------------040802060206090200020108--
