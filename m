From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] dccp: Convert DCCP_WARN to net_warn_ratelimited
Date: Thu, 06 Nov 2014 12:53:41 -0800
Message-ID: <1415307221.21526.0.camel@perches.com>
References: <1415230568.6634.36.camel@perches.com>
	 <1415230929.6634.38.camel@perches.com>
	 <20141106.151149.1321164537677873976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141106.151149.1321164537677873976.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the dependency on the "warning" sysctl (net_msg_warn)
which is only used by the LIMIT_NETDEBUG macro.

Convert the LIMIT_NETDEBUG use in DCCP_WARN to the more
common net_warn_ratelimited mechanism.

This still ratelimits based on the net_ratelimit()
function, but removes the check for the sysctl.

Signed-off-by: Joe Perches <joe@perches.com>
---
On Thu, 2014-11-06 at 15:11 -0500, David Miller wrote:
> Applied, thanks for doing this work Joe.
No worries.

What about the LIMIT_NETDEBUG stuff now?

Maybe all of them might as well be net_dbg_ratelimited
even if it changes some of the logging levels.

Probably DCCP_WARN should be net_warn_ratelimited
so let's start there...

 net/dccp/dccp.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index c678166..e4c144f 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -22,8 +22,8 @@
 /*
  * 	DCCP - specific warning and debugging macros.
  */
-#define DCCP_WARN(fmt, a...) LIMIT_NETDEBUG(KERN_WARNING "%s: " fmt,       \
-							__func__, ##a)
+#define DCCP_WARN(fmt, ...)						\
+	net_warn_ratelimited("%s: " fmt, __func__, ##__VA_ARGS__)
 #define DCCP_CRIT(fmt, a...) printk(KERN_CRIT fmt " at %s:%d/%s()\n", ##a, \
 					 __FILE__, __LINE__, __func__)
 #define DCCP_BUG(a...)       do { DCCP_CRIT("BUG: " a); dump_stack(); } while(0)
