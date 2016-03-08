From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/10] netfilter: xt_osf: remove unused variable
Date: Tue,  8 Mar 2016 11:00:44 +0100
Message-ID: <1457431250-3086-5-git-send-email-pablo@netfilter.org>
References: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40399 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932244AbcCHKBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 05:01:08 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 153AB8432
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id DE0C1DA395
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:06 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id F3E9828D236
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:03 +0100 (CET)
In-Reply-To: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>

While building with W=1 we got the warning:
net/netfilter/xt_osf.c:265:9: warning: variable 'loop_cont' set but not used

The local variable loop_cont was only initialized and then assigned a
value but was never used or checked after that.
While removing the variable, the case of OSFOPT_TS was not removed so
that it will serve as a reminder to us that we can do something in that
particular case.

Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_osf.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 4e3c3af..2455b69 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -262,7 +262,6 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 			if (f->opt[optnum].kind == (*optp)) {
 				__u32 len = f->opt[optnum].length;
 				const __u8 *optend = optp + len;
-				int loop_cont = 0;
 
 				fmatch = FMATCH_OK;
 
@@ -275,7 +274,6 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 					mss = ntohs((__force __be16)mss);
 					break;
 				case OSFOPT_TS:
-					loop_cont = 1;
 					break;
 				}
 
-- 
2.1.4
