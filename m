From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after
	some time
Date: Mon, 1 Sep 2008 19:01:02 +0200
Message-ID: <20080901170101.GA12236@pest>
References: <20080831182034.GA12035@pest> <OF9473413E.A12F091F-ON882574B7.00472B7A-882574B7.0047BD14@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:43065 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbYIARBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 13:01:06 -0400
Content-Disposition: inline
In-Reply-To: <OF9473413E.A12F091F-ON882574B7.00472B7A-882574B7.0047BD14@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 01, 2008 at 06:03:31AM -0700, David Stevens wrote:

> Well, it'd certainly be good to identify exactly where in
> the sendmsg path you're getting the EINVAL from. If
> possible, I'd suggest putting in some debugging code
> and reproducing it.

Do you have any suggestions/patches? I'm not an experienced programmer,
and since it usually takes a couple of hours for this problem to appear
I probably would need a few years to get anything reasonable.

Btw, it's happening again just right now (2.6.27-rc5), I've set a static
route so I can run some debugging without affecting the service. So if
you have any debugging commands you would like me to run this is the
time.

>  If you can pick up the exact arguments when it's happening
> via strace and send those here, that may help, but I wouldn't
> expect those to be incorrect from ping6 only some of the
> time...

The working group:

# strace -e recvmsg,sendmsg ping6 -c 1 -I eth0 ff02::2
recvmsg(4, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"0\0\0\0\24\0\2\0\22\37\274H4x\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1\10"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 108
recvmsg(4, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"@\0\0\0\24\0\2\0\22\37\274H4x\0\0\n\200\200\376\1\0\0\0\24\0\1\0\0\0\0\0\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 256
recvmsg(4, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0\22\37\274H4x\0\0\0\0\0\0\1\0\0\0\24\0\1\0\0\0\0\0\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::2", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0004x\0\1\22\37\274H\366\v\5\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=MSG_PEEK|MSG_PROXY|MSG_WAITALL|MSG_CONFIRM|MSG_FIN|MSG_SYN|MSG_RST|MSG_CMSG_CLOEXEC|0x8bc0000}, 0) = 64
recvmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(0), inet_pton(AF_INET6, "fe80::216:3eff:feb9:29f5", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=if_nametoindex("eth0")}, msg_iov(1)=[{"\201\0\305\n4x\0\1\22\37\274H\366\v\5\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 4208}], msg_controllen=36, {cmsg_len=20, cmsg_level=SOL_SOCKET, cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=0}, 0) = 64


The non-working RIPng group:
# strace -e recvmsg,sendmsg ping6 -c 1 -I eth0 ff02::9
recvmsg(4, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"0\0\0\0\24\0\2\0/\37\274HSx\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1\10"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 108
recvmsg(4, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"@\0\0\0\24\0\2\0/\37\274HSx\0\0\n\200\200\376\1\0\0\0\24\0\1\0\0\0\0\0\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 256
recvmsg(4, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0/\37\274HSx\0\0\0\0\0\0\1\0\0\0\24\0\1\0\0\0\0\0\0"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0Sx\0\1/\37\274H}\202\n\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=MSG_OOB|MSG_DONTROUTE|MSG_PEEK|MSG_CTRUNC|MSG_WAITALL|MSG_TRUNC|MSG_CONFIRM|MSG_FIN|MSG_SYN|MSG_RST|MSG_CMSG_CLOEXEC|0x8bc0000}, 0) = -1 EINVAL (Invalid argument)
recvmsg(3, 0xbf8c8350, MSG_ERRQUEUE|MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable)
sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0Sx\0\1/\37\274H\354\212\n\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=MSG_CTRUNC}, 0) = -1 EINVAL (Invalid argument)
recvmsg(3, 0xbf8c8350, MSG_ERRQUEUE|MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable)
ping: sendmsg: Invalid argument
recvmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(0), inet_pton(AF_INET6, "fe80::216:3eff:feb9:29f5", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=if_nametoindex("eth0")}, msg_iov(1)=[{"\201\0\374\223Sx\0\1/\37\274H}\202\n\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 4208}], msg_controllen=36, {cmsg_len=20, cmsg_level=SOL_SOCKET, cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=0}, 0) = 64


So the flags look different, but why?

Bernhard
