From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: ipv4-mapped ipv4 connect() for UDP broken in test10
Date: Wed, 26 Nov 2003 19:04:07 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031126.190407.102714104.yoshfuji@linux-ipv6.org>
References: <20031126081745.GA31415@codeblau.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: felix-kernel@fefe.de
In-Reply-To: <20031126081745.GA31415@codeblau.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031126081745.GA31415@codeblau.de> (at Wed, 26 Nov 2003 09:17:45 +0100), Felix von Leitner <felix-kernel@fefe.de> says:

> Some digging reveals that djbdns does this (with scope_id 0):
> 
>   socket(PF_INET6,...)
>   bind socket to ::
>   connect() socket to IP of peer (in this case, 210.81.13.179)
>   send() dns query
> 
> at this point, the query is not sent over ppp0 as it should, but it is
> sent to lo.  Not only that, but the queries are _received_ by the same
> djbdns (with servfail), although the destination IP is as said above
> 210.81.13.179 and none of my local IPs: 10.0.0.6, 127.0.0.1, or
> 217.88.123.45.

Please apply this patch.
(But I'm not sure this fix your problem...)

===== net/ipv6/udp.c 1.54 vs edited =====
--- 1.54/net/ipv6/udp.c	Tue Nov 18 11:41:56 2003
+++ edited/net/ipv6/udp.c	Wed Nov 26 19:01:15 2003
@@ -825,7 +825,7 @@
 			struct sockaddr_in sin;
 			sin.sin_family = AF_INET;
 			sin.sin_port = sin6 ? sin6->sin6_port : inet->dport;
-			sin.sin_addr.s_addr = daddr->s6_addr[3];
+			sin.sin_addr.s_addr = daddr->s6_addr32[3];
 			msg->msg_name = &sin;
 			msg->msg_namelen = sizeof(sin);
 do_udp_sendmsg:

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
