From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] IPV6: fix data offset calculation when pushing frag options {dst1opts|auth}
Date: Fri, 11 Jul 2003 02:27:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711002713.GC30577@rei.rakuen>
References: <20030710234449.GB30577@rei.rakuen> <20030711.091814.128467921.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, jmorris@intercode.com.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20030711.091814.128467921.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* yoshfuji@linux-ipv6.org wrote:
> +		exthdrlen += rt->u.dst.header_len + (opt ? opt->opt_flen : 0);

exthdrlen is uninitialized.

New patch:

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
+		exthdrlen = rt->u.dst.header_len + (opt ? opt->opt_flen : 0);
+		length += exthdrlen;
+		transhdrlen += exthdrlen;
 	} else {
 		rt = np->cork.rt;
 		if (inet->cork.flags & IPCORK_OPT)
