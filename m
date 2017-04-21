From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH 2/2] ipv6: don't deliver packets with zero length to raw
 sockets
Date: Fri, 21 Apr 2017 12:01:12 +0200
Message-ID: <20170421100112.GA4824@bistromath.localdomain>
References: <1492747124-31821-1-git-send-email-jbainbri@redhat.com>
 <1492747124-31821-2-git-send-email-jbainbri@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jamie Bainbridge <jbainbri@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44376 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1037631AbdDUKBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 06:01:16 -0400
Content-Disposition: inline
In-Reply-To: <1492747124-31821-2-git-send-email-jbainbri@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamie,

2017-04-21, 13:58:44 +1000, Jamie Bainbridge wrote:
> IPv6 assumes there is data after the network header and blindly delivers
> skbs to raw sockets without checking the presence of data.
> 
> With an application in a common loop where it checks select/poll/epoll
> then ioctl(SIOCINQ/FIONREAD) is positive before continuing to
> recvfrom(), this behaviour can cause the application to loop forever
> on ioctl() because there is a zero-length skb to receive.
> 
> With this, it is very easy to make a Denial of Service attack by
> crafting a packet which declares a Next Header in the IPv6 header but
> does not actually supply a transport header and/or payload.
> 
> skb->len is already correctly set in ip6_input_finish() with pskb_pull()
> so check this length before delivering zero data to raw sockets.

Isn't that changing behavior? recv() currently returns 0 when a packet
that stops right after the IP header arrives. After this, the userspace
program won't receive anything in this case?

-- 
Sabrina
