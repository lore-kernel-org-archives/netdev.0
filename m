From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 01/15] ax25: In ax25_rebuild_header add missing kfree_skb
Date: Sun, 01 Mar 2015 23:59:57 -0600
Message-ID: <87fv9o9bxe.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In the unlikely (impossible?) event that we attempt to transmit
an ax25 packet over a non-ax25 device free the skb so we don't
leak it.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-hams@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ax25/ax25_ip.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index 67de6b33f2c3..db3c283821d1 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -129,6 +129,7 @@ int ax25_rebuild_header(struct sk_buff *skb)
 		dev = skb->dev;
 
 	if ((ax25_dev = ax25_dev_ax25dev(dev)) == NULL) {
+		kfree_skb(skb);
 		goto put;
 	}
 
-- 
2.2.1

