From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/3]
 /proc/net/{igmp,msfilter,raw,rt_cache,ip6_flowlabel,msfilter6,raw6} may
 drop some data (Re: /proc/net/* read drops data)
Date: Sat, 06 Sep 2003 16:10:44 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030906.161044.46842553.yoshfuji@linux-ipv6.org>
References: <20030904004638.1d4b001d.davem@redhat.com>
	<Pine.GSO.4.33.0309041223430.13584-100000@sweetums.bluetronic.net>
	<20030906.160458.39800982.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
In-Reply-To: <20030906.160458.39800982.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[1/3] /proc/net/{igmp,msfilter,raw,rt_cache,ip6_flowlabel,msfilter6,raw6} may drop some data

Index: linux-2.6/net/ipv4/igmp.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/igmp.c,v
retrieving revision 1.34
diff -u -r1.34 igmp.c
--- linux-2.6/net/ipv4/igmp.c	1 Sep 2003 05:52:50 -0000	1.34
+++ linux-2.6/net/ipv4/igmp.c	6 Sep 2003 04:23:07 -0000
@@ -2162,7 +2162,7 @@
 static void *igmp_mc_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&dev_base_lock);
-	return *pos ? igmp_mc_get_idx(seq, *pos) : (void *)1;
+	return *pos ? igmp_mc_get_idx(seq, *pos - 1) : (void *)1;
 }
 
 static void *igmp_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
@@ -2337,7 +2337,7 @@
 static void *igmp_mcf_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&dev_base_lock);
-	return *pos ? igmp_mcf_get_idx(seq, *pos) : (void *)1;
+	return *pos ? igmp_mcf_get_idx(seq, *pos - 1) : (void *)1;
 }
 
 static void *igmp_mcf_seq_next(struct seq_file *seq, void *v, loff_t *pos)
Index: linux-2.6/net/ipv4/raw.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/raw.c,v
retrieving revision 1.35
diff -u -r1.35 raw.c
--- linux-2.6/net/ipv4/raw.c	11 Jul 2003 04:06:16 -0000	1.35
+++ linux-2.6/net/ipv4/raw.c	6 Sep 2003 04:23:07 -0000
@@ -736,7 +736,7 @@
 static void *raw_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&raw_v4_lock);
-	return *pos ? raw_get_idx(seq, *pos) : (void *)1;
+	return *pos ? raw_get_idx(seq, *pos - 1) : (void *)1;
 }
 
 static void *raw_seq_next(struct seq_file *seq, void *v, loff_t *pos)
Index: linux-2.6/net/ipv4/route.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/route.c,v
retrieving revision 1.58
diff -u -r1.58 route.c
--- linux-2.6/net/ipv4/route.c	1 Sep 2003 05:52:50 -0000	1.58
+++ linux-2.6/net/ipv4/route.c	6 Sep 2003 04:23:07 -0000
@@ -259,7 +259,7 @@
 
 static void *rt_cache_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	return *pos ? rt_cache_get_idx(seq, *pos) : (void *)1;
+	return *pos ? rt_cache_get_idx(seq, *pos - 1) : (void *)1;
 }
 
 static void *rt_cache_seq_next(struct seq_file *seq, void *v, loff_t *pos)
Index: linux-2.6/net/ipv6/ip6_flowlabel.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ip6_flowlabel.c,v
retrieving revision 1.8
diff -u -r1.8 ip6_flowlabel.c
--- linux-2.6/net/ipv6/ip6_flowlabel.c	2 Sep 2003 14:48:07 -0000	1.8
+++ linux-2.6/net/ipv6/ip6_flowlabel.c	6 Sep 2003 04:23:07 -0000
@@ -603,7 +603,7 @@
 static void *ip6fl_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock_bh(&ip6_fl_lock);
-	return *pos ? ip6fl_get_idx(seq, *pos) : (void *)1;
+	return *pos ? ip6fl_get_idx(seq, *pos - 1) : (void *)1;
 }
 
 static void *ip6fl_seq_next(struct seq_file *seq, void *v, loff_t *pos)
Index: linux-2.6/net/ipv6/mcast.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/mcast.c,v
retrieving revision 1.31
diff -u -r1.31 mcast.c
--- linux-2.6/net/ipv6/mcast.c	1 Sep 2003 05:52:50 -0000	1.31
+++ linux-2.6/net/ipv6/mcast.c	6 Sep 2003 04:23:07 -0000
@@ -2278,7 +2278,7 @@
 static void *igmp6_mcf_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&dev_base_lock);
-	return *pos ? igmp6_mcf_get_idx(seq, *pos) : (void *)1;
+	return *pos ? igmp6_mcf_get_idx(seq, *pos - 1) : (void *)1;
 }
 
 static void *igmp6_mcf_seq_next(struct seq_file *seq, void *v, loff_t *pos)
Index: linux-2.6/net/ipv6/raw.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/raw.c,v
retrieving revision 1.37
diff -u -r1.37 raw.c
--- linux-2.6/net/ipv6/raw.c	18 Aug 2003 10:14:52 -0000	1.37
+++ linux-2.6/net/ipv6/raw.c	6 Sep 2003 04:23:07 -0000
@@ -961,7 +961,7 @@
 static void *raw6_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&raw_v6_lock);
-	return *pos ? raw6_get_idx(seq, *pos) : (void *)1;
+	return *pos ? raw6_get_idx(seq, *pos - 1) : (void *)1;
 }
 
 static void *raw6_seq_next(struct seq_file *seq, void *v, loff_t *pos)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
