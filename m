From: Eric Leblond <eric@inl.fr>
Subject: [PATCH 1/3] netfilter: fix warning about invalid const usage
Date: Thu, 26 Mar 2009 08:59:54 +0100
Message-ID: <1238054396-9088-1-git-send-email-eric@inl.fr>
References: <1238053819.13879.4.camel@ice-age>
Cc: linux-next@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Eric Leblond <eric@inl.fr>
To: davem@davemloft.net, kaber@trash.net, sfr@canb.auug.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1238053819.13879.4.camel@ice-age>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the declaration of the logger structure in ebt_log
and ebt_ulog: I forgot to remove the const option from their declaration
in the commit ca735b3aaa945626ba65a3e51145bfe4ecd9e222 ("netfilter:
use a linked list of loggers").

Pointed-out-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Eric Leblond <eric@inl.fr>
---
 net/bridge/netfilter/ebt_log.c  |    2 +-
 net/bridge/netfilter/ebt_ulog.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index d44cbf8..a94f3cc 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -214,7 +214,7 @@ static struct xt_target ebt_log_tg_reg __read_mostly = {
 	.me		= THIS_MODULE,
 };
 
-static const struct nf_logger ebt_log_logger = {
+static struct nf_logger ebt_log_logger __read_mostly = {
 	.name 		= "ebt_log",
 	.logfn		= &ebt_log_packet,
 	.me		= THIS_MODULE,
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 2c6d682..80c78c5 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -279,7 +279,7 @@ static struct xt_target ebt_ulog_tg_reg __read_mostly = {
 	.me		= THIS_MODULE,
 };
 
-static const struct nf_logger ebt_ulog_logger = {
+static struct nf_logger ebt_ulog_logger __read_mostly = {
 	.name		= "ulog",
 	.logfn		= &ebt_log_packet,
 	.me		= THIS_MODULE,
-- 
1.5.6.3

