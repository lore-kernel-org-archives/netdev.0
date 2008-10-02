From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-next 5/9] netns: register global ipv6 mibs statistics in
	each namespace
Date: Thu,  2 Oct 2008 14:14:08 +0400
Message-ID: <1222942452-9820-5-git-send-email-den@openvz.org>
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

Unused net variable will become used very soon.

Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/ipv6/proc.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 7601f56..c38c9e5 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -175,6 +175,8 @@ snmp6_seq_show_item(struct seq_file *seq, void **mib, struct snmp_mib *itemlist)
 
 static int snmp6_seq_show(struct seq_file *seq, void *v)
 {
+	struct net *net = (struct net *)seq->private;
+
 	snmp6_seq_show_item(seq, (void **)ipv6_statistics, snmp6_ipstats_list);
 	snmp6_seq_show_item(seq, (void **)icmpv6_statistics, snmp6_icmp6_list);
 	snmp6_seq_show_icmpv6msg(seq, (void **)icmpv6msg_statistics);
@@ -185,7 +187,7 @@ static int snmp6_seq_show(struct seq_file *seq, void *v)
 
 static int snmp6_seq_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, snmp6_seq_show, NULL);
+	return single_open_net(inode, file, snmp6_seq_show);
 }
 
 static const struct file_operations snmp6_seq_fops = {
@@ -193,7 +195,7 @@ static const struct file_operations snmp6_seq_fops = {
 	.open	 = snmp6_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = single_release,
+	.release = single_release_net,
 };
 
 static int snmp6_dev_seq_show(struct seq_file *seq, void *v)
-- 
1.5.3.rc5
