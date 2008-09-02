From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after
	some time
Date: Tue, 2 Sep 2008 17:00:08 +0200
Message-ID: <20080902150008.GD7289@schleppi.birkenwald.de>
References: <20080831182034.GA12035@pest> <OF9473413E.A12F091F-ON882574B7.00472B7A-882574B7.0047BD14@us.ibm.com> <20080901170101.GA12236@pest> <48BD463E.6040408@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:45473 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbYIBPAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 11:00:11 -0400
Content-Disposition: inline
In-Reply-To: <48BD463E.6040408@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Brian,

>> So the flags look different, but why?
> Well, at least in the ping6 sources I have, msg_flags is never  
> initialized before the sendmsg() call, and since it's allocated on the  
> stack it can have random bits set.  Can you rebuild your ping6 with the  
> attached patch and retry?

Done, no change.

sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::2", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0\3252\0\0010T\275H\274\314\7\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=0}, 0) = 64

vs. 

sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0\3162\0\1+T\275H\255K\16\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=0}, 0) = -1 EINVAL (Invalid argument)

don't push too hard on ping6, I just included it to show that all
processes are affected sending to this particular group.

Bernhard
