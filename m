From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: XT_MATCH_REALM Kconfig whinge...
Date: Wed, 12 Jan 2011 21:57:31 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101122156310.27393@obet.zrqbmnf.qr>
References: <20519.1294859715@localhost> <4D2E057D.30707@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Valdis.Kletnieks@vt.edu, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:33012 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753457Ab1ALU5c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 15:57:32 -0500
In-Reply-To: <4D2E057D.30707@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 2011-01-12 20:48, Pablo Neira Ayuso wrote:

>On 12/01/11 20:15, Valdis.Kletnieks@vt.edu wrote:
>> scripts/kconfig/conf --silentoldconfig Kconfig
>> warning: (NETFILTER_XT_MATCH_REALM) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)
>> warning: (NETFILTER_XT_MATCH_REALM) selects NET_CLS_ROUTE which has unmet direct dependencies (NET && NET_SCHED)
>
>Does this fix your problem?
>

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


This patch is not right. The select should just be removed, because
xt_realm is useful even without SCHED and CLS_ROUTE.
