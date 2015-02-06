From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] pktgen: fix UDP checksum computation
Date: Thu, 05 Feb 2015 16:28:02 -0800
Message-ID: <1423182482.31870.99.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423087730-9201-1-git-send-email-sd@queasysnail.net>
	 <CA+mtBx9dT5JkDzj8AYojZBrm5-fd0GN0ZxY47t-43sZoqZmGsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sabrina Dubroca <sd@queasysnail.net>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:61379 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbbBFA2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 19:28:04 -0500
Received: by mail-ig0-f174.google.com with SMTP id b16so3395581igk.1
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 16:28:03 -0800 (PST)
In-Reply-To: <CA+mtBx9dT5JkDzj8AYojZBrm5-fd0GN0ZxY47t-43sZoqZmGsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-05 at 15:57 -0800, Tom Herbert wrote:

> Would it be possible to use udp_set_csum to handle all of this?

This reminds me we have following sparse errors with checksum code,
could you take a look Tom ?

make C=2 CF=-D__CHECK_ENDIAN__  ...

include/linux/skbuff.h:3022:24: warning: incorrect type in return expression (different base types)
include/linux/skbuff.h:3022:24:    expected restricted __sum16
include/linux/skbuff.h:3022:24:    got int

net/ipv6/ip6_checksum.c:83:16: warning: incorrect type in return expression (different base types)
net/ipv6/ip6_checksum.c:83:16:    expected int
net/ipv6/ip6_checksum.c:83:16:    got restricted __sum16 [assigned] [usertype] __ret

  CHECK   net/ipv4/tcp_offload.c
net/ipv4/tcp_offload.c:139:60: warning: incorrect type in argument 2 (different base types)
net/ipv4/tcp_offload.c:139:60:    expected restricted __wsum [usertype] res
net/ipv4/tcp_offload.c:139:60:    got fouled restricted __sum16
include/linux/skbuff.h:3317:14: warning: incorrect type in assignment (different base types)
include/linux/skbuff.h:3317:14:    expected unsigned short [unsigned] [usertype] csum
include/linux/skbuff.h:3317:14:    got restricted __sum16
include/linux/skbuff.h:3322:16: warning: incorrect type in return expression (different base types)
include/linux/skbuff.h:3322:16:    expected restricted __sum16
include/linux/skbuff.h:3322:16:    got unsigned short [unsigned] [usertype] csum
net/ipv4/tcp_offload.c:173:52: warning: incorrect type in argument 2 (different base types)
net/ipv4/tcp_offload.c:173:52:    expected restricted __wsum [usertype] res
net/ipv4/tcp_offload.c:173:52:    got fouled restricted __sum16
include/linux/skbuff.h:3317:14: warning: incorrect type in assignment (different base types)
include/linux/skbuff.h:3317:14:    expected unsigned short [unsigned] [usertype] csum
include/linux/skbuff.h:3317:14:    got restricted __sum16
include/linux/skbuff.h:3322:16: warning: incorrect type in return expression (different base types)
include/linux/skbuff.h:3322:16:    expected restricted __sum16
include/linux/skbuff.h:3322:16:    got unsigned short [unsigned] [usertype] csum
