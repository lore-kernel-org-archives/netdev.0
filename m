From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: oops in udpv6_sendmsg
Date: Wed, 26 Jun 2013 02:29:56 -0700
Message-ID: <1372238996.3301.149.camel@edumazet-glaptop>
References: <20130329184006.GA23893@redhat.com>
	 <1364582958.5113.49.camel@edumazet-glaptop>
	 <1364865839.5113.165.camel@edumazet-glaptop>
	 <20130417010213.GA9027@redhat.com>
	 <1366164132.3205.21.camel@edumazet-glaptop>
	 <20130417141138.GA17648@redhat.com>
	 <1366208856.3205.23.camel@edumazet-glaptop>
	 <1366214751.3205.29.camel@edumazet-glaptop>
	 <20130625212851.GA20081@order.stressinduktion.org>
	 <1372238557.3301.145.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:36071 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab3FZJ3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 05:29:53 -0400
Received: by mail-ea0-f178.google.com with SMTP id l15so7282775eak.37
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 02:29:52 -0700 (PDT)
In-Reply-To: <1372238557.3301.145.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-26 at 02:22 -0700, Eric Dumazet wrote:
> ip6_rt_put
> 
> Oh well...
> 
> It sounds we mix ipv4/ipv6 dst on an IPV6 socket.
> 
> So an IPV4 actor thinks he got a "struct rtable" pointer and messes
> critical fields which overlay struct rt6_info components, for example
> rt6i_node
> 
> rt6_inode  shares the same storage with : 
> 
> rt_type/rt_is_input/rt_uses_gateway/rt_iif
> 
> In my case, rt_iif is 0
> 
> CC Steffen Klassert, because of commit
> 8141ed9fcedb278f4a3a78680591bef1e55f75fb
> ("ipv4: Add a socket release callback for datagram sockets")

ip6_sk_dst_lookup_flow()/ip6_sk_dst_check() look buggy, they assume the
socket dst is an IPv6 one.

But its not true if ip4_datagram_connect() was called before.
