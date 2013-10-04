From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] net: ipv4 only populate IP_PKTINFO when
 needed
Date: Fri, 04 Oct 2013 14:20:10 -0700
Message-ID: <1380921610.3564.43.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380914896-24754-1-git-send-email-shawn.bohrer@gmail.com>
	 <1380914896-24754-4-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, tomk@rgmadvisors.com,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:44462 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610Ab3JDVUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 17:20:12 -0400
Received: by mail-pa0-f47.google.com with SMTP id kp14so4717665pab.34
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 14:20:11 -0700 (PDT)
In-Reply-To: <1380914896-24754-4-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-04 at 14:28 -0500, Shawn Bohrer wrote:
> From: Shawn Bohrer <sbohrer@rgmadvisors.com>
> 
> The since the removal of the routing cache computing
> fib_compute_spec_dst() does a fib_table lookup for each UDP multicast
> packet received.  This has introduced a performance regression for some
> UDP workloads.
> 
> This change skips populating the packet info for sockets that do not have
> IP_PKTINFO set.
> 
> Benchmark results from a netperf UDP_RR test:
> Before 89789.68 transactions/s
> After  90587.62 transactions/s
> 
> Benchmark results from a fio 1 byte UDP multicast pingpong test
> (Multicast one way unicast response):
> Before 12.63us RTT
> After  12.48us RTT
> 
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> ---
> v2 changes:
> 
> * ipv4_pktinfo_prepare() now takes a const struct sock*


Acked-by: Eric Dumazet <edumazet@google.com>
