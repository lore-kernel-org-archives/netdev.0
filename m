From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [RESEND 1/3]
 /proc/net/{igmp,msfilter,raw,rt_cache,ip6_flowlabel,msfilter6,raw6} may
 drop some data
Date: Wed, 10 Sep 2003 11:53:49 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030910.115349.78624567.yoshfuji@linux-ipv6.org>
References: <20030904004638.1d4b001d.davem@redhat.com>
	<Pine.GSO.4.33.0309041223430.13584-100000@sweetums.bluetronic.net>
	<20030906.160458.39800982.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
In-Reply-To: <20030906.160458.39800982.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <20030906.160458.39800982.yoshfuji@linux-ipv6.org> (at Sat, 06 Sep 2003 16:04:58 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> [1/3] /proc/net/{igmp,msfilter,raw,rt_cache,ip6_flowlabel,msfilter6,raw6} may drop some data
:
> Note 0: These confilct with SEQ_START_TOKEN patches; 
>         I'll regenerate if SEQ_START_TOKEN accepted.

Index: linux-2.6/net/ipv4/igmp.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/igmp.c,v
retrieving revision 1.35
diff -u -r1.35 igmp.c
--- linux-2.6/net/ipv4/igmp.c	9 Sep 2003 23:24:51 -0000	1.35
+++ linux-2.6/net/ipv4/igmp.c	10 Sep 2003 01:00:49 -0000
@@ -2162,7 +2162,7 @@
 static void *igmp_mc_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&dev_base_lock);
-	return *pos ? igmp_mc_get_idx(seq, *pos) : SEQ_START_TOKEN;
+	return *pos ? igmp_mc_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *igmp_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
@@ -2337,7 +2337,7 @@
 static void *igmp_mcf_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&dev_base_lock);
-	return *pos ? igmp_mcf_get_idx(seq, *pos) : SEQ_START_TOKEN;
+	return *pos ? igmp_mcf_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *igmp_mcf_seq_next(struct seq_file *seq, void *v, loff_t *pos)
Index: linux-2.6/net/ipv4/raw.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/raw.c,v
retrieving revision 1.36
diff -u -r1.36 raw.c
--- linux-2.6/net/ipv4/raw.c	9 Sep 2003 23:24:51 -0000	1.36
+++ linux-2.6/net/ipv4/raw.c	10 Sep 2003 01:00:49 -0000
@@ -736,7 +736,7 @@
 static void *raw_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&raw_v4_lock);
-	return *pos ? raw_get_idx(seq, *pos) : SEQ_START_TOKEN;
+	return *pos ? raw_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *raw_seq_next(struct seq_file *seq, void *v, loff_t *pos)
Index: linux-2.6/net/ipv4/route.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/route.c,v
retrieving revision 1.59
diff -u -r1.59 route.c
--- linux-2.6/net/ipv4/route.c	9 Sep 2003 23:24:51 -0000	1.59
+++ linux-2.6/net/ipv4/route.c	10 Sep 2003 01:00:49 -0000
@@ -259,7 +259,7 @@
 
 static void *rt_cache_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	return *pos ? rt_cache_get_idx(seq, *pos) : SEQ_START_TOKEN;
+	return *pos ? rt_cache_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *rt_cache_seq_next(struct seq_file *seq, void *v, loff_t *pos)
Index: linux-2.6/net/ipv6/ip6_flowlabel.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ip6_flowlabel.c,v
retrieving revision 1.9
diff -u -r1.9 ip6_flowlabel.c
--- linux-2.6/net/ipv6/ip6_flowlabel.c	9 Sep 2003 23:24:51 -0000	1.9
+++ linux-2.6/net/ipv6/ip6_flowlabel.c	10 Sep 2003 01:00:49 -0000
@@ -603,7 +603,7 @@
 static void *ip6fl_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock_bh(&ip6_fl_lock);
-	return *pos ? ip6fl_get_idx(seq, *pos) : SEQ_START_TOKEN;
+	return *pos ? ip6fl_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *ip6fl_seq_next(struct seq_file *seq, void *v, loff_t *pos)
Index: linux-2.6/net/ipv6/mcast.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/mcast.c,v
retrieving revision 1.32
diff -u -r1.32 mcast.c
--- linux-2.6/net/ipv6/mcast.c	9 Sep 2003 23:24:51 -0000	1.32
+++ linux-2.6/net/ipv6/mcast.c	10 Sep 2003 01:00:49 -0000
@@ -2278,7 +2278,7 @@
 static void *igmp6_mcf_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&dev_base_lock);
-	return *pos ? igmp6_mcf_get_idx(seq, *pos) : SEQ_START_TOKEN;
+	return *pos ? igmp6_mcf_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *igmp6_mcf_seq_next(struct seq_file *seq, void *v, loff_t *pos)
Index: linux-2.6/net/ipv6/raw.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/raw.c,v
retrieving revision 1.38
diff -u -r1.38 raw.c
--- linux-2.6/net/ipv6/raw.c	9 Sep 2003 23:24:51 -0000	1.38
+++ linux-2.6/net/ipv6/raw.c	10 Sep 2003 01:00:49 -0000
@@ -961,7 +961,7 @@
 static void *raw6_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&raw_v6_lock);
-	return *pos ? raw6_get_idx(seq, *pos) : SEQ_START_TOKEN;
+	return *pos ? raw6_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
 static void *raw6_seq_next(struct seq_file *seq, void *v, loff_t *pos)


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
