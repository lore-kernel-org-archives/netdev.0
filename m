From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH] iov_iter: don't revert if csum error
Date: Fri, 28 Apr 2017 20:48:45 +0800
Message-ID: <080dafec-c57f-0546-4d2f-ce4a31222e25@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, <pabeni@redhat.com>,
        <edumazet@google.com>, <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        LinuxArm <linuxarm@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch 3278682 (make skb_copy_datagram_msg() et.al. preserve
->msg_iter on error) will revert the iov buffer if copy to iter
failed, but it looks no need to revert for csum error, so fix it.

Fixes: 3278682 ("make skb_copy_datagram_msg() et.al. preserve->msg_iter on error")
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/core/datagram.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index f4947e7..475a8e9 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -760,7 +760,7 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,

 	if (msg_data_left(msg) < chunk) {
 		if (__skb_checksum_complete(skb))
-			goto csum_error;
+			goto fault;
 		if (skb_copy_datagram_msg(skb, hlen, msg, chunk))
 			goto fault;
 	} else {
-- 
1.8.3.1
