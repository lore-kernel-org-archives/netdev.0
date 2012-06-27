From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp demux used to signal ip_route_input_noref to not
 cache dst
Date: Wed, 27 Jun 2012 10:18:24 +0200
Message-ID: <1340785104.26242.9.camel@edumazet-glaptop>
References: <1340781553.10893.414.camel@edumazet-glaptop>
	 <1340783533.26242.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62507 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727Ab2F0ISa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:18:30 -0400
Received: by eeit10 with SMTP id t10so230608eei.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 01:18:29 -0700 (PDT)
In-Reply-To: <1340783533.26242.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 09:52 +0200, Eric Dumazet wrote:

> I'll test the following patch in a moment.
> 
> For the moment, set nocache to true for all frames not associated to an
> ESTABLISHED socket. Not sure we want to test SYN flag after all.
> 
>  include/net/protocol.h |    2 +-
>  include/net/route.h    |    8 ++++----
>  include/net/tcp.h      |    2 +-
>  net/ipv4/arp.c         |    2 +-
>  net/ipv4/ip_fragment.c |    2 +-
>  net/ipv4/ip_input.c    |    5 +++--
>  net/ipv4/route.c       |    8 +++++---
>  net/ipv4/tcp_ipv4.c    |    4 +++-
>  net/ipv4/xfrm4_input.c |    2 +-
>  9 files changed, 20 insertions(+), 15 deletions(-)

Excellent results.

I am now able to resist to DDOS synflood attacks, with no route cache
pollution, and no more rt_garbage_collect() hits.
