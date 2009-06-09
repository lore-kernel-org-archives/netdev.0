From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Subject: [PATCH RESEND] ftrace: change the export format of trace_kfree_skb()
Date: Tue, 09 Jun 2009 13:54:39 +0800
Message-ID: <4A2DF91F.7030906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Ingo <mingo@elte.hu>, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	David Miller <davem@
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56829 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754186AbZFIFyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 01:54:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use %pf instead of %p to output the function's address, use 0x%04X instead
of %u to output the skb's protocol

Before patch:

          <idle>-0     [000] 60144.542521: kfree_skb: skbaddr=de7b8240 protocol=2048 location=c1365429
          <idle>-0     [000] 60164.488153: kfree_skb: skbaddr=da66f900 protocol=2048 location=c1365429
          <idle>-0     [000] 60193.493933: kfree_skb: skbaddr=deaeb480 protocol=4 location=c134ec25
          <idle>-0     [000] 60253.118421: kfree_skb: skbaddr=de7c4900 protocol=4 location=c134ec25
          
After patch:

            bash-2587  [001] 97685.781173: kfree_skb: skbaddr=deb9cc00 protocol=0x0000 location=netlink_unicast
            bash-2587  [000] 97686.501121: kfree_skb: skbaddr=df9bb840 protocol=0x0000 location=netlink_unicast
          <idle>-0     [000] 97696.200184: kfree_skb: skbaddr=df741240 protocol=0x0800 location=ip_rcv
          <idle>-0     [000] 97696.200198: kfree_skb: skbaddr=dfb3de40 protocol=0x0800 location=ip_rcv

Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
---

Recover the file mode of include/trace/events/skb.h

---
 include/trace/events/skb.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
index 1e8fabb..a58bef8 100644
--- a/include/trace/events/skb.h
+++ b/include/trace/events/skb.h
@@ -30,7 +30,7 @@ TRACE_EVENT(kfree_skb,
 		__entry->location = location;
 	),
 
-	TP_printk("skbaddr=%p protocol=%u location=%p",
+	TP_printk("skbaddr=%p protocol=0x%04X location=%pf",
 		__entry->skbaddr, __entry->protocol, __entry->location)
 );
 
-- 
1.6.1.2

