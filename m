From: Eric Leblond <eric@inl.fr>
Subject: netfilter: xt_NFLOG is dependant of nfnetlink_log
Date: Wed, 10 Dec 2008 19:49:17 +0100
Message-ID: <1228934957-11967-1-git-send-email-eric@inl.fr>
References: <1228934630.5961.8.camel@ice-age>
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, kaber@trash.net,
	Eric Leblond <eric@inl.fr>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1228934630.5961.8.camel@ice-age>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch "don't call nf_log_packet in NFLOG module" make xt_NFLOG
dependant of nfnetlink_log. This patch forces the dependencies to fix
compilation in case only xt_NFLOG compilation was asked and modifies the
help message accordingly to the change.

Signed-off-by: Eric Leblond <eric@inl.fr>
---
 net/netfilter/Kconfig |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 25dcef9..c2bac9c 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -373,11 +373,10 @@ config NETFILTER_XT_TARGET_MARK
 config NETFILTER_XT_TARGET_NFLOG
 	tristate '"NFLOG" target support'
 	default m if NETFILTER_ADVANCED=n
+	select NETFILTER_NETLINK_LOG
 	help
 	  This option enables the NFLOG target, which allows to LOG
-	  messages through the netfilter logging API, which can use
-	  either the old LOG target, the old ULOG target or nfnetlink_log
-	  as backend.
+	  messages through nfnetlink_log.
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-- 
1.5.6.3

