From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [RESEND 3/3] clean up /proc/net/{anycast6,igmp6}
Date: Wed, 10 Sep 2003 11:53:56 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030910.115356.107533747.yoshfuji@linux-ipv6.org>
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

> In article <Pine.GSO.4.33.0309041223430.13584-100000@sweetums.bluetronic.net> (at Thu, 4 Sep 2003 12:25:16 -0400 (EDT))
> [3/3] clean up /proc/net/{anycast6,igmp6}
:
> Note 0: These confilct with SEQ_START_TOKEN patches; 
>         I'll regenerate if SEQ_START_TOKEN accepted.

Index: linux-2.6/net/ipv6/anycast.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/anycast.c,v
retrieving revision 1.7
diff -u -r1.7 anycast.c
--- linux-2.6/net/ipv6/anycast.c	25 Jul 2003 17:11:54 -0000	1.7
+++ linux-2.6/net/ipv6/anycast.c	10 Sep 2003 01:00:49 -0000
@@ -505,7 +505,7 @@
 static void *ac6_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&dev_base_lock);
-	return *pos ? ac6_get_idx(seq, *pos) : ac6_get_first(seq);
+	return ac6_get_idx(seq, *pos);
 }
 
 static void *ac6_seq_next(struct seq_file *seq, void *v, loff_t *pos)
Index: linux-2.6/net/ipv6/mcast.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/mcast.c,v
retrieving revision 1.32
diff -u -r1.32 mcast.c
--- linux-2.6/net/ipv6/mcast.c	9 Sep 2003 23:24:51 -0000	1.32
+++ linux-2.6/net/ipv6/mcast.c	10 Sep 2003 01:00:49 -0000
@@ -2119,7 +2119,7 @@
 static void *igmp6_mc_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&dev_base_lock);
-	return *pos ? igmp6_mc_get_idx(seq, *pos) : igmp6_mc_get_first(seq);
+	return igmp6_mc_get_idx(seq, *pos);
 }
 
 static void *igmp6_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
