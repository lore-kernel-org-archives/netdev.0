From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: fix data offset calculation when pushing frag
 options {dst1opts|auth}
Date: Fri, 11 Jul 2003 09:24:35 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711.092435.64560380.yoshfuji@linux-ipv6.org>
References: <20030710234449.GB30577@rei.rakuen>
	<20030711.091814.128467921.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch, davem@redhat.com, jmorris@intercode.com.au
In-Reply-To: <20030711.091814.128467921.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030711.091814.128467921.yoshfuji@linux-ipv6.org> (at Fri, 11 Jul 2003 09:18:14 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> D: fix offset of payload with extension header.
> D: based on patch from Thomas Graf <tgraf@suug.ch>

Oops, thas wrong again; please use this instead...

Index: linux-2.5/net/ipv6/ip6_output.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ip6_output.c,v
retrieving revision 1.33
diff -u -r1.33 ip6_output.c
--- linux-2.5/net/ipv6/ip6_output.c	9 Jul 2003 05:55:17 -0000	1.33
+++ linux-2.5/net/ipv6/ip6_output.c	10 Jul 2003 23:02:56 -0000
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

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
