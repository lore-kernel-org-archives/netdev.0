From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Subject: [PATCH] netfilter:Change nf_conntrack modules to use vmalloc
Date: Tue, 4 Mar 2014 15:30:36 +0800
Message-ID: <35FD53F367049845BC99AC72306C23D102844605F39A@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D102844605F38C@CNBJMBX05.corpusers.net>
 <53104ECA.4010702@freescale.com>
 <35FD53F367049845BC99AC72306C23D102844605F38D@CNBJMBX05.corpusers.net>
 <20140228163304.GA15614@kroah.com>
 <35FD53F367049845BC99AC72306C23D102844605F38F@CNBJMBX05.corpusers.net>
 <20140303030821.GA16732@kroah.com>
 <35FD53F367049845BC99AC72306C23D102844605F390@CNBJMBX05.corpusers.net>
 <20140303141044.GA9139@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'alsa-devel@alsa-project.org'" <alsa-devel@alsa-project.org>,
 "'broonie@opensource.wolfsonmicro.com'"
 <broonie@opensource.wolfsonmicro.com>, "'tiwai@suse.de'" <tiwai@suse.de>,
 "'fweisbec@gmail.com'" <fweisbec@gmail.com>,
 'Will Deacon' <will.deacon@arm.com>, "'perex@perex.cz'" <perex@perex.cz>,
 "'mingo@redhat.com'" <mingo@redhat.com>,
 "'linux-input@vger.kernel.org'" <linux-input@vger.kernel.org>,
 "'rydberg@euromail.se'" <rydberg@euromail.se>, "'lrg@ti.com'" <lrg@ti.com>,
 "'pablo@netfilter.org'" <pablo@netfilter.org>,
 "'rusty@rustcorp.com.au'" <rusty@rustcorp.com.au>,
 "'coreteam@netfilter.org'" <coreteam@netfilter.org>,
 "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>,
 "'mschmidt@redhat.com'" <mschmidt@redhat.com>,
 "'rostedt@goodmis.org'" <rostedt@goodmis.org>,
 "'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
 "'linux-arm-kernel@lists.infradead
To: "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20140303141044.GA9139@kroah.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch change some nf_conntrack modules to
use vmalloc to allocate large memory instead of kmalloc,
to save low memorys.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 net/netfilter/nf_conntrack_ftp.c       | 6 +++---
 net/netfilter/nf_conntrack_h323_main.c | 8 ++++----
 net/netfilter/nf_conntrack_irc.c       | 6 +++---
 net/netfilter/nf_conntrack_sane.c      | 6 +++---
 4 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index b8a0924..aad7eca 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -14,7 +14,7 @@
 #include <linux/moduleparam.h>
 #include <linux/netfilter.h>
 #include <linux/ip.h>
-#include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <linux/ipv6.h>
 #include <linux/ctype.h>
 #include <linux/inet.h>
@@ -593,14 +593,14 @@ static void nf_conntrack_ftp_fini(void)
 		}
 	}
 
-	kfree(ftp_buffer);
+	vfree(ftp_buffer);
 }
 
 static int __init nf_conntrack_ftp_init(void)
 {
 	int i, j = -1, ret = 0;
 
-	ftp_buffer = kmalloc(65536, GFP_KERNEL);
+	ftp_buffer = vmalloc(65536);
 	if (!ftp_buffer)
 		return -ENOMEM;
 
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 70866d1..5baee1a 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -18,7 +18,7 @@
 #include <linux/inet.h>
 #include <linux/in.h>
 #include <linux/ip.h>
-#include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <linux/udp.h>
 #include <linux/tcp.h>
 #include <linux/skbuff.h>
@@ -1837,7 +1837,7 @@ static void __exit nf_conntrack_h323_fini(void)
 	nf_conntrack_helper_unregister(&nf_conntrack_helper_q931[1]);
 	nf_conntrack_helper_unregister(&nf_conntrack_helper_q931[0]);
 	nf_conntrack_helper_unregister(&nf_conntrack_helper_h245);
-	kfree(h323_buffer);
+	vfree(h323_buffer);
 	pr_debug("nf_ct_h323: fini\n");
 }
 
@@ -1846,7 +1846,7 @@ static int __init nf_conntrack_h323_init(void)
 {
 	int ret;
 
-	h323_buffer = kmalloc(65536, GFP_KERNEL);
+	h323_buffer = vmalloc(65536);
 	if (!h323_buffer)
 		return -ENOMEM;
 	ret = nf_conntrack_helper_register(&nf_conntrack_helper_h245);
@@ -1876,7 +1876,7 @@ err3:
 err2:
 	nf_conntrack_helper_unregister(&nf_conntrack_helper_h245);
 err1:
-	kfree(h323_buffer);
+	vfree(h323_buffer);
 	return ret;
 }
 
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 0fd2976..b57df10 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -16,7 +16,7 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/netfilter.h>
-#include <linux/slab.h>
+#include <linux/vmalloc.h>
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_expect.h>
@@ -244,7 +244,7 @@ static int __init nf_conntrack_irc_init(void)
 	irc_exp_policy.max_expected = max_dcc_channels;
 	irc_exp_policy.timeout = dcc_timeout;
 
-	irc_buffer = kmalloc(65536, GFP_KERNEL);
+	irc_buffer = vmalloc(65536);
 	if (!irc_buffer)
 		return -ENOMEM;
 
@@ -285,7 +285,7 @@ static void nf_conntrack_irc_fini(void)
 
 	for (i = 0; i < ports_c; i++)
 		nf_conntrack_helper_unregister(&irc[i]);
-	kfree(irc_buffer);
+	vfree(irc_buffer);
 }
 
 module_init(nf_conntrack_irc_init);
diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_conntrack_sane.c
index 4a2134f..a4c8bf3 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -20,7 +20,7 @@
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/netfilter.h>
-#include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <linux/in.h>
 #include <linux/tcp.h>
 #include <net/netfilter/nf_conntrack.h>
@@ -185,14 +185,14 @@ static void nf_conntrack_sane_fini(void)
 		}
 	}
 
-	kfree(sane_buffer);
+	vfree(sane_buffer);
 }
 
 static int __init nf_conntrack_sane_init(void)
 {
 	int i, j = -1, ret = 0;
 
-	sane_buffer = kmalloc(65536, GFP_KERNEL);
+	sane_buffer = vmalloc(65536);
 	if (!sane_buffer)
 		return -ENOMEM;
 
-- 
1.8.2.2
