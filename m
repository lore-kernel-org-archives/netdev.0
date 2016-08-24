From: "Xue, Ying" <Ying.Xue@windriver.com>
Subject: Re: [PATCH -next] tipc: use kfree_skb() instead
	of kfree()
Date: Wed, 24 Aug 2016 02:47:32 +0000
Message-ID: <25A14D9CFAB7B34FB9440F90AFD35233010193E3DF@ALA-MBA.corp.ad.wrs.com>
References: <1471993262-4061-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Yongjun <weiyongjun1@huawei.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: Wei Yongjun <weiyj.lk@gmail.com>, Jon Maloy <jon.maloy@ericsson.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1471993262-4061-1-git-send-email-weiyj.lk@gmail.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Acked-by: Ying Xue <ying.xue@windriver.com>

-----Original Message-----
From: Wei Yongjun [mailto:weiyj.lk@gmail.com] 
Sent: Wednesday, August 24, 2016 7:01 AM
To: Jon Maloy; Xue, Ying; David S. Miller
Cc: Wei Yongjun; netdev@vger.kernel.org; tipc-discussion@lists.sourceforge.net
Subject: [PATCH -next] tipc: use kfree_skb() instead of kfree()

From: Wei Yongjun <weiyongjun1@huawei.com>

Use kfree_skb() instead of kfree() to free sk_buff.

Fixes: 0d051bf93c06 ("tipc: make bearer packet filtering generic")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/tipc/bearer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c index 6fc4e3c..28056fa 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -529,7 +529,7 @@ void tipc_bearer_xmit(struct net *net, u32 bearer_id,
 		if (likely(test_bit(0, &b->up) || msg_is_reset(buf_msg(skb))))
 			b->media->send_msg(net, skb, b, dst);
 		else
-			kfree(skb);
+			kfree_skb(skb);
 	}
 	rcu_read_unlock();
 }

------------------------------------------------------------------------------
