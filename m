From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] strip: remove warnings when !PROC_FS
Date: Mon, 23 Feb 2004 13:47:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223134704.568fec18.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.3-current.

--
~Randy


From: Luiz Fernando Capitulino <lcapitulino@prefeitura.sp.gov.br>


hi guys,

When !CONFIG_PROC_FS, I'm getting this warning:

drivers/net/wireless/strip.c:1169: warning: `strip_seq_fops' defined but not used

This patch fixes that.

diff -X dontdiff -Nru linux-2.6.2-rc2-bk2/drivers/net/wireless/strip.c linux-2.6.2-rc2-bk2~/drivers/net/wireless/strip.c


 linux-263-kj1-rddunlap/drivers/net/wireless/strip.c |    2 ++
 1 files changed, 2 insertions(+)

diff -puN drivers/net/wireless/strip.c~net_strip_noprocfs drivers/net/wireless/strip.c
--- linux-263-kj1/drivers/net/wireless/strip.c~net_strip_noprocfs	2004-02-18 14:46:34.000000000 -0800
+++ linux-263-kj1-rddunlap/drivers/net/wireless/strip.c	2004-02-18 14:46:34.000000000 -0800
@@ -951,6 +951,7 @@ static void strip_unlock(struct strip *s
  * ascii representation of the number plus 9 charactes for the " seconds"
  * and the null character.
  */
+#ifdef CONFIG_PROC_FS
 static char *time_delta(char buffer[], long time)
 {
 	time -= jiffies;
@@ -1171,6 +1172,7 @@ static struct file_operations strip_seq_
 	.llseek  = seq_lseek,
 	.release = seq_release,
 };
+#endif
 
 
 

_
