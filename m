From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] IPV6: fix data offset calculation when pushing frag options {dst1opts|auth}
Date: Fri, 11 Jul 2003 01:44:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710234449.GB30577@rei.rakuen>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, jmorris@intercode.com.au, yoshfuji@linux-ipv6.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

ip6_append_data:
The offset in the datagram where the payload gets copied
to (transhdrlen) is not calculated correctly: the size
of frag opts {dst1opt|auth} is not taken into account.
This lead to overwritten payload by frag opts.

yoshfuji agreed on this.

patch is against 2.5.75

 -- thomas


Index: net/ipv6/ip6_output.c
===================================================================
RCS file: /cvs/tgr/linux-25/net/ipv6/ip6_output.c,v
retrieving revision 1.1.1.2
diff -u -r1.1.1.2 ip6_output.c
--- net/ipv6/ip6_output.c	10 Jul 2003 22:58:50 -0000	1.1.1.2
+++ net/ipv6/ip6_output.c	10 Jul 2003 23:36:48 -0000
@@ -1247,11 +1247,9 @@
 		inet->cork.length = 0;
 		inet->sndmsg_page = NULL;
 		inet->sndmsg_off = 0;
-		if ((exthdrlen = rt->u.dst.header_len) != 0) {
-			length += exthdrlen;
-			transhdrlen += exthdrlen;
-		}
-		exthdrlen += opt ? opt->opt_flen : 0;
+		exthdrlen = rt->u.dst.header_len + opt ? opt->opt_flen : 0;
+		length += exthdrlen;
+		transhdrlen += exthdrlen;
 	} else {
 		rt = np->cork.rt;
 		if (inet->cork.flags & IPCORK_OPT)
