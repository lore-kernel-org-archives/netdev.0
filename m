From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] classifier: report statistics for basic classifier
Date: Thu, 4 Nov 2010 17:47:04 -0400
Message-ID: <20101104174704.573c52e4@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52695 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753124Ab0KDVrI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 17:47:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The basic classifier keeps statistics but does not report it to user space.
This showed up when using basic classifier (with police) as a default catch
all on ingress; no statistics were reported.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
I consider this a bug and should go into net-2.6 but not stable.

 net/sched/cls_basic.c |    4 ++++
 1 file changed, 4 insertions(+)

--- a/net/sched/cls_basic.c	2010-11-04 16:06:19.984953193 -0400
+++ b/net/sched/cls_basic.c	2010-11-04 16:06:42.248953192 -0400
@@ -268,6 +268,10 @@ static int basic_dump(struct tcf_proto *
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
+
+	if (tcf_exts_dump_stats(skb, &f->exts, &basic_ext_map) < 0)
+		goto nla_put_failure;
+
 	return skb->len;
 
 nla_put_failure:
