From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: fix data offset calculation when pushing frag
 options {dst1opts|auth}
Date: Fri, 11 Jul 2003 09:18:14 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711.091814.128467921.yoshfuji@linux-ipv6.org>
References: <20030710234449.GB30577@rei.rakuen>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch, davem@redhat.com, jmorris@intercode.com.au
In-Reply-To: <20030710234449.GB30577@rei.rakuen>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030710234449.GB30577@rei.rakuen> (at Fri, 11 Jul 2003 01:44:49 +0200), Thomas Graf <tgraf@suug.ch> says:

> yoshfuji agreed on this.

I agreed, but

> -		exthdrlen += opt ? opt->opt_flen : 0;
> +		exthdrlen = rt->u.dst.header_len + opt ? opt->opt_flen : 0;

Well, sorry, this was wrong.

D: fix offset of payload with extension header.
D: based on patch from Thomas Graf <tgraf@suug.ch>

Index: linux-2.5/net/ipv6/ip6_output.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ip6_output.c,v
retrieving revision 1.33
diff -u -r1.33 ip6_output.c
--- linux-2.5/net/ipv6/ip6_output.c	9 Jul 2003 05:55:17 -0000	1.33
+++ linux-2.5/net/ipv6/ip6_output.c	10 Jul 2003 22:50:33 -0000
@@ -1247,11 +1247,9 @@
 		inet->cork.length = 0;
 		inet->sndmsg_page = NULL;
 		inet->sndmsg_off = 0;
-		if ((exthdrlen = rt->u.dst.header_len) != 0) {
-			length += exthdrlen;
-			transhdrlen += exthdrlen;
-		}
-		exthdrlen += opt ? opt->opt_flen : 0;
+		exthdrlen += rt->u.dst.header_len + (opt ? opt->opt_flen : 0);
+		length += exthdrlen;
+		transhdrlen += exthdrlen;
 	} else {
 		rt = np->cork.rt;
 		if (inet->cork.flags & IPCORK_OPT)

--yoshfuji
