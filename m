From: weiyj_lk@163.com
Subject: [PATCH -next] fou: Fix missing unlock on error in fou_nl_dump()
Date: Thu, 16 Apr 2015 20:14:39 +0800
Message-ID: <1429186479-20265-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	WANG Cong <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:59588 "EHLO m12-15.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754513AbbDPMPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2015 08:15:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add the missing unlock before return from function fou_nl_dump()
in the error handling case.

Fixes: 7a6c8c34e5b7 (fou: implement FOU_CMD_GET)
Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/ipv4/fou.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index af150b4..6ca0182 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -711,7 +711,7 @@ static int fou_nl_dump(struct sk_buff *skb, struct netlink_callback *cb)
 				    cb->nlh->nlmsg_seq, NLM_F_MULTI,
 				    skb, FOU_CMD_GET);
 		if (ret)
-			goto done;
+			break;
 	}
 	mutex_unlock(&fn->fou_lock);
 
