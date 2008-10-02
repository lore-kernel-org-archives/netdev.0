From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-next 3/9] ipv6: consolidate ipv6 sock_stat code at the
	beginning of net/ipv6/proc.c
Date: Thu,  2 Oct 2008 14:14:06 +0400
Message-ID: <1222942452-9820-3-git-send-email-den@openvz.org>
References: <1222942394.6327.5.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org,
        benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1222942394.6327.5.camel-aPCOdVxUTlgvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Simple, comsolidate sockstat6 staff in one place, at the beginning of
the file. Right now sockstat6_seq_open/sockstat6_seq_fops looks like an
intrusion in the middle of snmp6 code.

Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/ipv6/proc.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 5764062..25eda8b 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -46,6 +46,19 @@ static int sockstat6_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
+static int sockstat6_seq_open(struct inode *inode, struct file *file)
+{
+	return single_open_net(inode, file, sockstat6_seq_show);
+}
+
+static const struct file_operations sockstat6_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = sockstat6_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = single_release_net,
+};
+
 static struct snmp_mib snmp6_ipstats_list[] = {
 /* ipv6 mib according to RFC 2465 */
 	SNMP_MIB_ITEM("Ip6InReceives", IPSTATS_MIB_INRECEIVES),
@@ -179,19 +192,6 @@ static int snmp6_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-static int sockstat6_seq_open(struct inode *inode, struct file *file)
-{
-	return single_open_net(inode, file, sockstat6_seq_show);
-}
-
-static const struct file_operations sockstat6_seq_fops = {
-	.owner	 = THIS_MODULE,
-	.open	 = sockstat6_seq_open,
-	.read	 = seq_read,
-	.llseek	 = seq_lseek,
-	.release = single_release_net,
-};
-
 static int snmp6_seq_open(struct inode *inode, struct file *file)
 {
 	return single_open(file, snmp6_seq_show, PDE(inode)->data);
-- 
1.5.3.rc5
