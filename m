From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] fou: Don't use const __read_mostly
Date: Wed,  8 Apr 2015 06:04:31 -0700
Message-ID: <1428498271-6345-1-git-send-email-andi@firstfloor.org>
Cc: therbert@google.com, Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([193.170.194.197]:38590 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbbDHNHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 09:07:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

const __read_mostly is a senseless combination. If something
is already const it cannot be __read_mostly. Remove the bogus
__read_mostly in the fou driver.

This fixes section conflicts with LTO.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 net/ipv4/fou.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index ff069f6..335e752 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -771,12 +771,12 @@ EXPORT_SYMBOL(gue_build_header);
 
 #ifdef CONFIG_NET_FOU_IP_TUNNELS
 
-static const struct ip_tunnel_encap_ops __read_mostly fou_iptun_ops = {
+static const struct ip_tunnel_encap_ops fou_iptun_ops = {
 	.encap_hlen = fou_encap_hlen,
 	.build_header = fou_build_header,
 };
 
-static const struct ip_tunnel_encap_ops __read_mostly gue_iptun_ops = {
+static const struct ip_tunnel_encap_ops gue_iptun_ops = {
 	.encap_hlen = gue_encap_hlen,
 	.build_header = gue_build_header,
 };
-- 
2.3.3
