From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] NET: disconnect support by null address (is Re:
 Disconnecting a connected UDP socket)
Date: Fri, 04 Jul 2003 02:28:57 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030704.022857.07343571.yoshfuji@linux-ipv6.org>
References: <20030703031610.79050.qmail@web20704.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: shibu_lkml@yahoo.com, davem@redhat.com, jmorris@intercode.com.au
In-Reply-To: <20030703031610.79050.qmail@web20704.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <20030703031610.79050.qmail@web20704.mail.yahoo.com> (at Wed, 2 Jul 2003 20:16:10 -0700 (PDT)), Shibu LKML <shibu_lkml@yahoo.com> says:

> I am wondering if Linux supports disconnecting a connected UDP socket. The manpage for connect lists it in the BUGS section. It says disconnect is still not supported. I was wondering if it involves more than adding the following lines to udp_connect in udp.c
>  
> if (usin->sin_family == AF_UNSPEC)
>   return udp_disconnect(sk, 0);
> 
> (just  above sk_dst_reset(sk))
>  
> Will this fix the problem for IPV4 stuff? 

It seems.  Please apply this.

Index: linux-2.5/net/ipv4/udp.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv4/udp.c,v
retrieving revision 1.36
diff -u -r1.36 udp.c
--- linux-2.5/net/ipv4/udp.c	21 Jun 2003 16:20:28 -0000	1.36
+++ linux-2.5/net/ipv4/udp.c	3 Jul 2003 16:01:29 -0000
@@ -868,6 +868,9 @@
 	if (addr_len < sizeof(*usin)) 
 	  	return -EINVAL;
 
+	if (usin->sin_family == AF_UNSPEC)
+		return udp_disconnect(sk, 0);
+
 	if (usin->sin_family != AF_INET) 
 	  	return -EAFNOSUPPORT;
 
Index: linux-2.5/net/ipv6/udp.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/udp.c,v
retrieving revision 1.39
diff -u -r1.39 udp.c
--- linux-2.5/net/ipv6/udp.c	1 Jul 2003 16:42:06 -0000	1.39
+++ linux-2.5/net/ipv6/udp.c	3 Jul 2003 16:01:29 -0000
@@ -213,6 +213,9 @@
 	int			addr_type;
 	int			err;
 
+	if (usin->sin6_family == AF_UNSPEC)
+		return udp_disconnect(sk, 0);
+
 	if (usin->sin6_family == AF_INET) {
 		if (__ipv6_only_sock(sk))
 			return -EAFNOSUPPORT;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
