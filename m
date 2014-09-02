From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/7] netfilter: NETFILTER_XT_TARGET_LOG selects NF_LOG_*
Date: Tue,  2 Sep 2014 12:14:04 +0200
Message-ID: <1409652844-10289-8-git-send-email-pablo@netfilter.org>
References: <1409652844-10289-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48088 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753363AbaIBKN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 06:13:28 -0400
In-Reply-To: <1409652844-10289-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_NETFILTER_XT_TARGET_LOG is not selected anymore when jumping
from 3.16 to 3.17-rc1 if you don't set on the new NF_LOG_IPV4 and
NF_LOG_IPV6 switches.

Change this to select the three new symbols NF_LOG_COMMON, NF_LOG_IPV4
and NF_LOG_IPV6 instead, so NETFILTER_XT_TARGET_LOG remains enabled
when moving from old to new kernels.

Reported-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 05eb177..4bef6eb 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -747,7 +747,9 @@ config NETFILTER_XT_TARGET_LED
=20
 config NETFILTER_XT_TARGET_LOG
 	tristate "LOG target support"
-	depends on NF_LOG_IPV4 && NF_LOG_IPV6
+	select NF_LOG_COMMON
+	select NF_LOG_IPV4
+	select NF_LOG_IPV6 if IPV6
 	default m if NETFILTER_ADVANCED=3Dn
 	help
 	  This option adds a `LOG' target, which allows you to create rules i=
n
--=20
1.7.10.4
