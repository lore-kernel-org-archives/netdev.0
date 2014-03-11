From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 10/11] benet: Call dev_kfree_skby_any instead of kfree_skb.
Date: Mon, 10 Mar 2014 20:23:50 -0700
Message-ID: <87ob1do1tl.fsf_-_@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<871ty9qvaf.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42854 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753845AbaCKDX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:23:56 -0400
In-Reply-To: <871ty9qvaf.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 10 Mar 2014 20:16:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace free_skb with dev_kfree_skb_any in be_tx_compl_process as which
can be called in hard irq by netpoll, softirq context by normal napi
polling, and in normal sleepable context by the network device close
method.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6e10230a2ee0..2eee0b2577f8 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1897,7 +1897,7 @@ static u16 be_tx_compl_process(struct be_adapter *adapter,
 		queue_tail_inc(txq);
 	} while (cur_index != last_index);
 
-	kfree_skb(sent_skb);
+	dev_kfree_skb_any(sent_skb);
 	return num_wrbs;
 }
 
-- 
1.7.5.4
