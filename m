From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net] net/sched: cls_flower: Correct matching on ICMPv6 code
Date: Mon, 30 Jan 2017 16:19:02 +0100
Message-ID: <1485789542-6346-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f180.google.com ([209.85.210.180]:35886 "EHLO
        mail-wj0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932354AbdA3PTN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 10:19:13 -0500
Received: by mail-wj0-f180.google.com with SMTP id n2so6911296wjq.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 07:19:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When matching on the ICMPv6 code ICMPV6_CODE rather than
ICMPV4_CODE attributes should be used.

This corrects what appears to be a typo.

Sample usage:

tc qdisc add dev eth0 ingress
tc filter add dev eth0 protocol ipv6 parent ffff: flower \
	indev eth0 ip_proto icmpv6 type 128 code 0 action drop

Without this change the code parameter above is effectively ignored.

Fixes: 7b684884fbfa ("net/sched: cls_flower: Support matching on ICMP type and code")
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/sched/cls_flower.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 970db7a41684..5752789acc13 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -568,9 +568,9 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 			       &mask->icmp.type,
 			       TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,
 			       sizeof(key->icmp.type));
-		fl_set_key_val(tb, &key->icmp.code, TCA_FLOWER_KEY_ICMPV4_CODE,
+		fl_set_key_val(tb, &key->icmp.code, TCA_FLOWER_KEY_ICMPV6_CODE,
 			       &mask->icmp.code,
-			       TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
+			       TCA_FLOWER_KEY_ICMPV6_CODE_MASK,
 			       sizeof(key->icmp.code));
 	}
 
-- 
2.7.0.rc3.207.g0ac5344
