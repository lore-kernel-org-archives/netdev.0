From: Joe Perches <joe@perches.com>
Subject: [RFC net-next 1/2] net: Add net_ratelimited_function and net_<level>_ratelimited macros
Date: Mon, 14 May 2012 00:56:25 -0700
Message-ID: <96871aa331061e890357662c22633926dd42ffa9.1336981915.git.joe@perches.com>
References: <cover.1336981915.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1336981915.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

__ratelimit() can be considered an inverted bool test because
it returns true when not ratelimited.  Several tests in the
kernel tree use this __ratelimit() function incorrectly.

No net_ratelimit uses are incorrect currently though.

Most uses of net_ratelimit are to log something via printk or
pr_<level>.

In order to minimize the uses of net_ratelimit, and to start
standardizing the code style used for __ratelimit() and net_ratelimit(),
add a net_ratelimited_function() macro and net_<level>_ratelimited()
logging macros similar to pr_<level>_ratelimited that use the global
net_ratelimit instead of a static per call site "struct ratelimit_state".

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/net.h |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index be60c7f..2d7510f 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -250,6 +250,29 @@ extern struct socket *sockfd_lookup(int fd, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
 extern int	     net_ratelimit(void);
 
+#define net_ratelimited_function(function, ...)			\
+do {								\
+	if (net_ratelimit())					\
+		function(__VA_ARGS__);				\
+} while (0)
+
+#define net_emerg_ratelimited(fmt, ...)				\
+	net_ratelimited_function(pr_emerg, fmt, ##__VA_ARGS__)
+#define net_alert_ratelimited(fmt, ...)				\
+	net_ratelimited_function(pr_alert, fmt, ##__VA_ARGS__)
+#define net_crit_ratelimited(fmt, ...)				\
+	net_ratelimited_function(pr_crit, fmt, ##__VA_ARGS__)
+#define net_err_ratelimited(fmt, ...)				\
+	net_ratelimited_function(pr_err, fmt, ##__VA_ARGS__)
+#define net_notice_ratelimited(fmt, ...)			\
+	net_ratelimited_function(pr_notice, fmt, ##__VA_ARGS__)
+#define net_warn_ratelimited(fmt, ...)				\
+	net_ratelimited_function(pr_warn, fmt, ##__VA_ARGS__)
+#define net_info_ratelimited(fmt, ...)				\
+	net_ratelimited_function(pr_info, fmt, ##__VA_ARGS__)
+#define net_dbg_ratelimited(fmt, ...)				\
+	net_ratelimited_function(pr_debug, fmt, ##__VA_ARGS__)
+
 #define net_random()		random32()
 #define net_srandom(seed)	srandom32((__force u32)seed)
 
-- 
1.7.8.111.gad25c.dirty
