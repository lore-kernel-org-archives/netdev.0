From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/4] netfilter: nf_tables: fix bogus warning in nft_data_uninit()
Date: Sat, 16 May 2015 20:47:18 +0200
Message-ID: <1431802038-4502-5-git-send-email-pablo@netfilter.org>
References: <1431802038-4502-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42836 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751964AbbEPSmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 May 2015 14:42:42 -0400
In-Reply-To: <1431802038-4502-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mirek Kratochvil <exa.exa@gmail.com>

The values 0x00000000-0xfffffeff are reserved for userspace datatype. When,
deleting set elements with maps, a bogus warning is triggered.

WARNING: CPU: 0 PID: 11133 at net/netfilter/nf_tables_api.c:4481 nft_data_uninit+0x35/0x40 [nf_tables]()

This fixes the check accordingly to enum definition in
include/linux/netfilter/nf_tables.h

Fixes: https://bugzilla.netfilter.org/show_bug.cgi?id=1013
Signed-off-by: Mirek Kratochvil <exa.exa@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index ad9d11f..34ded09 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4472,9 +4472,9 @@ EXPORT_SYMBOL_GPL(nft_data_init);
  */
 void nft_data_uninit(const struct nft_data *data, enum nft_data_types type)
 {
-	switch (type) {
-	case NFT_DATA_VALUE:
+	if (type < NFT_DATA_VERDICT)
 		return;
+	switch (type) {
 	case NFT_DATA_VERDICT:
 		return nft_verdict_uninit(data);
 	default:
-- 
1.7.10.4
