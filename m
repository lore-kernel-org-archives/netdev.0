From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 09/10] benet: Call dev_kfree_skby_any instead of kfree_skb.
Date: Tue, 11 Mar 2014 14:19:50 -0700
Message-ID: <87d2hsa0w9.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<87r468bfqj.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57739 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754055AbaCKVT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:19:56 -0400
In-Reply-To: <87r468bfqj.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 14:13:56 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace free_skb with dev_kfree_skb_any in be_tx_compl_process as
which can be called in hard irq by netpoll, softirq context
by normal napi polling, and in normal sleepable context
by the network device close method.

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
