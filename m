From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v4 net-next 1/4] net: change
 sysctl_net_ll_poll into an unsigned int
Date: Fri, 14 Jun 2013 04:56:49 +0300
Message-ID: <20130614015648.3500.85865.stgit@ladj378.jer.intel.com>
References: <20130614015638.3500.61523.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Kehati <ork@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	linux-kernel@vger.kernel.org, Alex Rosenbaum <alexr@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	sockperf-dev@googlegroups.com, Avner Ben Hanoch <avnerb@mellanox.com>,
	Andi Kleen <andi@firstfloor.org>, Eliezer Tamir <eliezer@tamir.org.il>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130614015638.3500.61523.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

There is no reason for sysctl_net_ll_poll to be an unsigned long.
Change it into an unsigned int.
Fix the proc handler.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 include/net/ll_poll.h      |    5 +++--
 net/core/sysctl_net_core.c |    4 ++--
 net/socket.c               |    2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h
index bc262f8..44e2f70 100644
--- a/include/net/ll_poll.h
+++ b/include/net/ll_poll.h
@@ -34,7 +34,7 @@
 #ifdef CONFIG_NET_LL_RX_POLL
 
 struct napi_struct;
-extern unsigned long sysctl_net_ll_poll __read_mostly;
+extern unsigned int sysctl_net_ll_poll __read_mostly;
 
 /* return values from ndo_ll_poll */
 #define LL_FLUSH_FAILED		-1
@@ -45,7 +45,8 @@ extern unsigned long sysctl_net_ll_poll __read_mostly;
 
 static inline cycles_t ll_end_time(void)
 {
-	return TSC_MHZ * ACCESS_ONCE(sysctl_net_ll_poll) + get_cycles();
+	return (cycles_t)TSC_MHZ * ACCESS_ONCE(sysctl_net_ll_poll)
+			+ get_cycles();
 }
 
 static inline bool sk_valid_ll(struct sock *sk)
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 637a42e..ce9acc2 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -289,9 +289,9 @@ static struct ctl_table net_core_table[] = {
 	{
 		.procname	= "low_latency_poll",
 		.data		= &sysctl_net_ll_poll,
-		.maxlen		= sizeof(unsigned long),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_doulongvec_minmax
+		.proc_handler	= proc_dointvec
 	},
 #endif
 #endif /* CONFIG_NET */
diff --git a/net/socket.c b/net/socket.c
index 21fd29f..caaffa1 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -107,7 +107,7 @@
 #include <net/ll_poll.h>
 
 #ifdef CONFIG_NET_LL_RX_POLL
-unsigned long sysctl_net_ll_poll __read_mostly;
+unsigned int sysctl_net_ll_poll __read_mostly;
 EXPORT_SYMBOL_GPL(sysctl_net_ll_poll);
 #endif
 


------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
