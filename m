From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: XT_MATCH_REALM Kconfig whinge...
Date: Wed, 12 Jan 2011 22:08:12 +0100
Message-ID: <4D2E183C.4070908@netfilter.org>
References: <20519.1294859715@localhost> <4D2E057D.30707@netfilter.org> <alpine.LNX.2.01.1101122156310.27393@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010208050509060702040002"
Cc: Valdis.Kletnieks@vt.edu, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1101122156310.27393@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010208050509060702040002
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 12/01/11 21:57, Jan Engelhardt wrote:
> On Wednesday 2011-01-12 20:48, Pablo Neira Ayuso wrote:
> 
>> On 12/01/11 20:15, Valdis.Kletnieks@vt.edu wrote:
>>> scripts/kconfig/conf --silentoldconfig Kconfig
>>> warning: (NETFILTER_XT_MATCH_REALM) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)
>>> warning: (NETFILTER_XT_MATCH_REALM) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)
>>
>> Does this fix your problem?
>>
> 
> diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> index 1534f2b..ae56764 100644
> --- a/net/netfilter/Kconfig
> +++ b/net/netfilter/Kconfig
> @@ -886,7 +886,8 @@ config NETFILTER_XT_MATCH_RATEEST
>  config NETFILTER_XT_MATCH_REALM
>  	tristate  '"realm" match support'
>  	depends on NETFILTER_ADVANCED
> -	select NET_CLS_ROUTE
> +	depends on NET_SCHED
> +	depends on NET_CLS_ROUTE
>  	help
>  	  This option adds a `realm' match, which allows you to use the realm
>  	  key from the routing subsystem inside iptables.
> 
> 
> This patch is not right. The select should just be removed, because
> xt_realm is useful even without SCHED and CLS_ROUTE.

I wonder why NET_CLS_ROUTE has been there as dependency.

Then this patch should be fine.



--------------010208050509060702040002
Content-Type: text/x-patch;
 name="realm.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="realm.patch"

netfilter: xt_realm: fix unmet direct dependencies

From: Pablo Neira Ayuso <pablo@netfilter.org>

scripts/kconfig/conf --silentoldconfig Kconfig
warning: (NETFILTER_XT_MATCH_REALM) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)
warning: (NETFILTER_XT_MATCH_REALM) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)

Jan Engelhardt spotted that NET_CLS_ROUTE is a superfluous dependency,
for that reason, this patch remove it.

Reported by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 1534f2b..8960260 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -886,7 +886,6 @@ config NETFILTER_XT_MATCH_RATEEST
 config NETFILTER_XT_MATCH_REALM
 	tristate  '"realm" match support'
 	depends on NETFILTER_ADVANCED
-	select NET_CLS_ROUTE
 	help
 	  This option adds a `realm' match, which allows you to use the realm
 	  key from the routing subsystem inside iptables.

--------------010208050509060702040002--
