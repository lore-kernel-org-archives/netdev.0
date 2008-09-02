From: Brian Haley <brian.haley@hp.com>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after	some
 time
Date: Tue, 02 Sep 2008 09:57:18 -0400
Message-ID: <48BD463E.6040408@hp.com>
References: <20080831182034.GA12035@pest> <OF9473413E.A12F091F-ON882574B7.00472B7A-882574B7.0047BD14@us.ibm.com> <20080901170101.GA12236@pest>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060607060709040403070702"
Cc: David Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org
To: Bernhard Schmidt <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:28502 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbYIBN5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 09:57:21 -0400
In-Reply-To: <20080901170101.GA12236@pest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060607060709040403070702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Bernhard Schmidt wrote:
> The working group:
> 
> # strace -e recvmsg,sendmsg ping6 -c 1 -I eth0 ff02::2
> recvmsg(4, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"0\0\0\0\24\0\2\0\22\37\274H4x\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1\10"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 108
> recvmsg(4, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"@\0\0\0\24\0\2\0\22\37\274H4x\0\0\n\200\200\376\1\0\0\0\24\0\1\0\0\0\0\0\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 256
> recvmsg(4, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0\22\37\274H4x\0\0\0\0\0\0\1\0\0\0\24\0\1\0\0\0\0\0\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
> sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::2", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0004x\0\1\22\37\274H\366\v\5\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=MSG_PEEK|MSG_PROXY|MSG_WAITALL|MSG_CONFIRM|MSG_FIN|MSG_SYN|MSG_RST|MSG_CMSG_CLOEXEC|0x8bc0000}, 0) = 64
> recvmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(0), inet_pton(AF_INET6, "fe80::216:3eff:feb9:29f5", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=if_nametoindex("eth0")}, msg_iov(1)=[{"\201\0\305\n4x\0\1\22\37\274H\366\v\5\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 4208}], msg_controllen=36, {cmsg_len=20, cmsg_level=SOL_SOCKET, cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=0}, 0) = 64
> 
> 
> The non-working RIPng group:
> # strace -e recvmsg,sendmsg ping6 -c 1 -I eth0 ff02::9
> recvmsg(4, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"0\0\0\0\24\0\2\0/\37\274HSx\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1\10"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 108
> recvmsg(4, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"@\0\0\0\24\0\2\0/\37\274HSx\0\0\n\200\200\376\1\0\0\0\24\0\1\0\0\0\0\0\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 256
> recvmsg(4, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0/\37\274HSx\0\0\0\0\0\0\1\0\0\0\24\0\1\0\0\0\0\0\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
> sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0Sx\0\1/\37\274H}\202\n\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=MSG_OOB|MSG_DONTROUTE|MSG_PEEK|MSG_CTRUNC|MSG_WAITALL|MSG_TRUNC|MSG_CONFIRM|MSG_FIN|MSG_SYN|MSG_RST|MSG_CMSG_CLOEXEC|0x8bc0000}, 0) = -1 EINVAL (Invalid argument)
> recvmsg(3, 0xbf8c8350, MSG_ERRQUEUE|MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable)
> sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0Sx\0\1/\37\274H\354\212\n\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=MSG_CTRUNC}, 0) = -1 EINVAL (Invalid argument)
> recvmsg(3, 0xbf8c8350, MSG_ERRQUEUE|MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable)
> ping: sendmsg: Invalid argument
> recvmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(0), inet_pton(AF_INET6, "fe80::216:3eff:feb9:29f5", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=if_nametoindex("eth0")}, msg_iov(1)=[{"\201\0\374\223Sx\0\1/\37\274H}\202\n\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 4208}], msg_controllen=36, {cmsg_len=20, cmsg_level=SOL_SOCKET, cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=0}, 0) = 64
> 
> 
> So the flags look different, but why?

Well, at least in the ping6 sources I have, msg_flags is never 
initialized before the sendmsg() call, and since it's allocated on the 
stack it can have random bits set.  Can you rebuild your ping6 with the 
attached patch and retry?

-Brian

--------------060607060709040403070702
Content-Type: text/x-patch;
 name="ping6.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ping6.diff"

diff -c ping6.c.orig ping6.c
*** ping6.c.orig	2008-09-02 09:29:30.000000000 -0400
--- ping6.c	2008-09-02 09:36:06.000000000 -0400
***************
*** 727,732 ****
--- 727,733 ----
  		mhdr.msg_namelen = sizeof(struct sockaddr_in6);
  		mhdr.msg_iov = &iov;
  		mhdr.msg_iovlen = 1;
+ 		mhdr.msg_flags = 0;
  		mhdr.msg_control = cmsgbuf;
  		mhdr.msg_controllen = cmsglen;
  

--------------060607060709040403070702--
