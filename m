From: Shaohua Li <shli@fb.com>
Subject: [PATCH trival -resend 2/2] lib: clean up put_cpu_var usage
Date: Tue, 27 Sep 2016 08:42:42 -0700
Message-ID: <935eea817a8d13d9223e09b4ca11e0508aee8437.1474990741.git.shli@fb.com>
References: <7ffd1960225e024a738e4c372f091bb49096e294.1474990741.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>,
        <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7ffd1960225e024a738e4c372f091bb49096e294.1474990741.git.shli@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

put_cpu_var takes the percpu data, not the data returned from
get_cpu_var.

This doesn't change the behavior.

Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 lib/random32.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/random32.c b/lib/random32.c
index a309235..fa594b1 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -81,7 +81,7 @@ u32 prandom_u32(void)
 	u32 res;
 
 	res = prandom_u32_state(state);
-	put_cpu_var(state);
+	put_cpu_var(net_rand_state);
 
 	return res;
 }
@@ -128,7 +128,7 @@ void prandom_bytes(void *buf, size_t bytes)
 	struct rnd_state *state = &get_cpu_var(net_rand_state);
 
 	prandom_bytes_state(state, buf, bytes);
-	put_cpu_var(state);
+	put_cpu_var(net_rand_state);
 }
 EXPORT_SYMBOL(prandom_bytes);
 
-- 
2.9.3
