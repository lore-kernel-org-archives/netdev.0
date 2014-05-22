From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] rsi: avoid format string leak to thread name
Date: Thu, 22 May 2014 11:48:41 -0700
Message-ID: <20140522184841.GA8625@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Fariya Fatima <fariyaf@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the rsi_create_kthread interface does not include any format
string arguments, make sure that the resulting thread name can never
accidentally process the name as a format string.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wireless/rsi/rsi_common.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rsi/rsi_common.h b/drivers/net/wireless/rsi/rsi_common.h
index f2f70784d4ad..d3fbe33d2324 100644
--- a/drivers/net/wireless/rsi/rsi_common.h
+++ b/drivers/net/wireless/rsi/rsi_common.h
@@ -63,7 +63,7 @@ static inline int rsi_create_kthread(struct rsi_common *common,
 				     u8 *name)
 {
 	init_completion(&thread->completion);
-	thread->task = kthread_run(func_ptr, common, name);
+	thread->task = kthread_run(func_ptr, common, "%s", name);
 	if (IS_ERR(thread->task))
 		return (int)PTR_ERR(thread->task);
 
-- 
1.7.9.5


-- 
Kees Cook
Chrome OS Security
