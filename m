From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] bpf: fix bpf_setsockopts return value
Date: Thu, 24 Aug 2017 15:48:21 -0700
Message-ID: <20170824224821.31672-1-ycheng@google.com>
Cc: ncardwell@google.com, cgallek@google.com, netdev@vger.kernel.org,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33612 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753627AbdHXWse (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 18:48:34 -0400
Received: by mail-pg0-f52.google.com with SMTP id t3so4782448pgt.0
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 15:48:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug causing any sock operations to always return EINVAL.

Fixes: a5192c52377e ("bpf: fix to bpf_setsockops").
Reported-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Craig Gallek <kraig@google.com>
---
 net/core/filter.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 6280a602604c..8eb81e5fae08 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2872,7 +2872,6 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
 				ret = -EINVAL;
 			}
 		}
-		ret = -EINVAL;
 #endif
 	} else {
 		ret = -EINVAL;
-- 
2.14.1.342.g6490525c54-goog
