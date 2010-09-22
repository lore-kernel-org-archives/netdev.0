From: kaber@trash.net
Subject: [PATCH 5/6] netfilter: nf_nat_snmp: fix checksum calculation (v4)
Date: Wed, 22 Sep 2010 09:17:33 +0200
Message-ID: <1285139854-11827-6-git-send-email-kaber@trash.net>
References: <1285139854-11827-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53999 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237Ab0IVHRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 03:17:38 -0400
In-Reply-To: <1285139854-11827-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Fix checksum calculation in nf_nat_snmp_basic.

Based on patches by Clark Wang <wtweeker@163.com> and
Stephen Hemminger <shemminger@vyatta.com>.

https://bugzilla.kernel.org/show_bug.cgi?id=17622

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_snmp_basic.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 1679e2c..ee5f419 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -893,13 +893,15 @@ static void fast_csum(__sum16 *csum,
 	unsigned char s[4];
 
 	if (offset & 1) {
-		s[0] = s[2] = 0;
+		s[0] = ~0;
 		s[1] = ~*optr;
+		s[2] = 0;
 		s[3] = *nptr;
 	} else {
-		s[1] = s[3] = 0;
 		s[0] = ~*optr;
+		s[1] = ~0;
 		s[2] = *nptr;
+		s[3] = 0;
 	}
 
 	*csum = csum_fold(csum_partial(s, 4, ~csum_unfold(*csum)));
-- 
1.7.1

