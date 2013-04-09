From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] netrom: fix invalid use of sizeof in nr_recvmsg()
Date: Tue, 9 Apr 2013 10:07:19 +0800
Message-ID: <CAPgLHd-yEmt_BJ52uZNsCA_-w85VhnN_HbfjG1QLVvR5kp7Xvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
To: ralf@linux-mips.org, minipli@googlemail.com, davem@davemloft.net
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

sizeof() when applied to a pointer typed expression gives the size of the
pointer, not that of the pointed data.
Introduced by commit 3ce5ef(netrom: fix info leak via msg_name in nr_recvmsg)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/netrom/af_netrom.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 7fcb307..103bd70 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1173,7 +1173,7 @@ static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 	if (sax != NULL) {
-		memset(sax, 0, sizeof(sax));
+		memset(sax, 0, sizeof(*sax));
 		sax->sax25_family = AF_NETROM;
 		skb_copy_from_linear_data_offset(skb, 7, sax->sax25_call.ax25_call,
 			      AX25_ADDR_LEN);

