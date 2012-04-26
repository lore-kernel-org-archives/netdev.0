From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] IPVS: ip_vs_proto.c: local functions should not be exposed globally
Date: Thu, 26 Apr 2012 11:26:15 -0700
Message-ID: <201204261126.15699.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail160.messagelabs.com ([216.82.253.99]:32710 "EHLO
	mail160.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758745Ab2DZS01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 14:26:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions not referenced outside of a source file should be marked
static to prevent it from being exposed globally.

This quiets the sparse warnings:

warning: symbol '__ipvs_proto_data_get' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: "David S. Miller" <davem@davemloft.net>

---

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 6eda11d..d5d1d92 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -153,7 +153,7 @@ EXPORT_SYMBOL(ip_vs_proto_get);
 /*
  *	get ip_vs_protocol object data by netns and proto
  */
-struct ip_vs_proto_data *
+static struct ip_vs_proto_data *
 __ipvs_proto_data_get(struct netns_ipvs *ipvs, unsigned short proto)
 {
 	struct ip_vs_proto_data *pd;
