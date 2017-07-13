From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH] bpf: fix return in bpf_skb_adjust_net
Date: Thu, 13 Jul 2017 14:27:58 +0800
Message-ID: <1499927278-175876-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        Kefeng Wang <wangkefeng.wang@huawei.com>
To: Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bpf_skb_adjust_net() ignores the return value of bpf_skb_net_shrink/grow,
and always return 0, fix it by return 'ret'.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 net/core/filter.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index c7f7370..f44fc22 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2248,7 +2248,7 @@ static int bpf_skb_adjust_net(struct sk_buff *skb, s32 len_diff)
 		       bpf_skb_net_grow(skb, len_diff_abs);
 
 	bpf_compute_data_end(skb);
-	return 0;
+	return ret;
 }
 
 BPF_CALL_4(bpf_skb_adjust_room, struct sk_buff *, skb, s32, len_diff,
-- 
1.8.3.1
