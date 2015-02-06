From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] pktgen: fix UDP checksum computation
Date: Fri, 6 Feb 2015 14:46:46 +0100
Message-ID: <20150206134646.GA30471@kria>
References: <1423087730-9201-1-git-send-email-sd@queasysnail.net>
 <CA+mtBx9dT5JkDzj8AYojZBrm5-fd0GN0ZxY47t-43sZoqZmGsg@mail.gmail.com>
 <1423182482.31870.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:2782 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755282AbbBFNqu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2015 08:46:50 -0500
Content-Disposition: inline
In-Reply-To: <1423182482.31870.99.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-02-05, 16:28:02 -0800, Eric Dumazet wrote:
> On Thu, 2015-02-05 at 15:57 -0800, Tom Herbert wrote:
> 
> > Would it be possible to use udp_set_csum to handle all of this?

I will look.


> This reminds me we have following sparse errors with checksum code,
> could you take a look Tom ?
> 
> make C=2 CF=-D__CHECK_ENDIAN__  ...
> 
> include/linux/skbuff.h:3022:24: warning: incorrect type in return expression (different base types)
> include/linux/skbuff.h:3022:24:    expected restricted __sum16
> include/linux/skbuff.h:3022:24:    got int
> 
> net/ipv6/ip6_checksum.c:83:16: warning: incorrect type in return expression (different base types)
> net/ipv6/ip6_checksum.c:83:16:    expected int
> net/ipv6/ip6_checksum.c:83:16:    got restricted __sum16 [assigned] [usertype] __ret
> 
>   CHECK   net/ipv4/tcp_offload.c
> net/ipv4/tcp_offload.c:139:60: warning: incorrect type in argument 2 (different base types)
> net/ipv4/tcp_offload.c:139:60:    expected restricted __wsum [usertype] res
> net/ipv4/tcp_offload.c:139:60:    got fouled restricted __sum16
> include/linux/skbuff.h:3317:14: warning: incorrect type in assignment (different base types)
> include/linux/skbuff.h:3317:14:    expected unsigned short [unsigned] [usertype] csum
> include/linux/skbuff.h:3317:14:    got restricted __sum16
> include/linux/skbuff.h:3322:16: warning: incorrect type in return expression (different base types)
> include/linux/skbuff.h:3322:16:    expected restricted __sum16
> include/linux/skbuff.h:3322:16:    got unsigned short [unsigned] [usertype] csum
> net/ipv4/tcp_offload.c:173:52: warning: incorrect type in argument 2 (different base types)
> net/ipv4/tcp_offload.c:173:52:    expected restricted __wsum [usertype] res
> net/ipv4/tcp_offload.c:173:52:    got fouled restricted __sum16
> include/linux/skbuff.h:3317:14: warning: incorrect type in assignment (different base types)
> include/linux/skbuff.h:3317:14:    expected unsigned short [unsigned] [usertype] csum
> include/linux/skbuff.h:3317:14:    got restricted __sum16
> include/linux/skbuff.h:3322:16: warning: incorrect type in return expression (different base types)
> include/linux/skbuff.h:3322:16:    expected restricted __sum16
> include/linux/skbuff.h:3322:16:    got unsigned short [unsigned] [usertype] csum

I have patches ready for that and other sparse warnings, I just need
to check and send them.


Thanks

-- 
Sabrina
