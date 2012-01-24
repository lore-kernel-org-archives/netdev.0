From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH -next] sunrpc: fix stats.h for CONFIG_PROC_FS not enabled
Date: Mon, 23 Jan 2012 19:28:07 -0800
Message-ID: <4F1E2547.1030206@xenotime.net>
References: <20120123141155.3e6b665ef655e267f25d4e7f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120123141155.3e6b665ef655e267f25d4e7f@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix build errors in linux/sunrpc/stats.h when CONFIG_PROC_FS
is not enabled:
- add parameter names to inline functions
- fix placement of '(' in rpc_proc_unregister()

Fixes these errors:
include/linux/sunrpc/stats.h:72:63: error: parameter name omitted
include/linux/sunrpc/stats.h:73:46: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'net'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---

 include/linux/sunrpc/stats.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -Naurp linux-next-20120123/include/linux/sunrpc/stats.h~prm_names linux-next-20120123/include/linux/sunrpc/stats.h
--- linux-next-20120123/include/linux/sunrpc/stats.h~prm_names	2012-01-23 19:19:49.000000000 -0800
+++ linux-next-20120123/include/linux/sunrpc/stats.h	2012-01-23 19:20:54.000000000 -0800
@@ -69,8 +69,8 @@ void			svc_seq_show(struct seq_file *,
 				     const struct svc_stat *);
 #else
 
-static inline struct proc_dir_entry *rpc_proc_register(struct net *, struct rpc_stat *s) { return NULL; }
-static inline void rpc_proc_unregisterstruct net *, (const char *p) {}
+static inline struct proc_dir_entry *rpc_proc_register(struct net *net, struct rpc_stat *s) { return NULL; }
+static inline void rpc_proc_unregister(struct net *net, const char *p) {}
 static inline void rpc_proc_zero(const struct rpc_program *p) {}
 
 static inline struct proc_dir_entry *svc_proc_register(struct net *net, struct svc_stat *s,
