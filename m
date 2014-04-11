From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: Limit mtu to 65572 bytes
Date: Fri, 11 Apr 2014 04:44:42 +0200
Message-ID: <20140411024442.GL27255@order.stressinduktion.org>
References: <5345A2B3.7040602@gmail.com> <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com> <20140409223546.GH27255@order.stressinduktion.org> <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com> <20140410235459.GK27255@order.stressinduktion.org> <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com> <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36473 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132AbaDKCoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 22:44:44 -0400
Content-Disposition: inline
In-Reply-To: <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 10, 2014 at 06:42:10PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Francois reported that setting big mtu on loopback device could prevent
> tcp sessions making progress.
> 
> We do not support (yet ?) IPv6 Jumbograms and cook corrupted packets.
> 
> We must limit the IPv6 MTU to (65535 + 40) bytes in theory.
> 
> In practice, its better to align to a multiple of 4 for optimal TCP
> performance.
> 
> Tested:
> 
> ifconfig lo mtu 70000
> netperf -H ::1
> 
> Before patch :
> 
> -> Throughput :   0.05 Mbits
> 
> After patch :
> 
> -> Throughput : 36624.24 Mbits
> 
> Reported-by: Francois WELLENREITER <f.wellenreiter@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Sorry about my wrong statement earlier in this thread, you're right.

Btw. this patch fixes a flaw in the UDP output path, too, where we didn't
generate EMSGSIZE error correctly before in all cases. udp_sendmsg only checks
for INT_MAX - sizeof(udphdr) and defers further checking to ip6_append_data
which seems to be prepared for jumbograms. ;)

Very cool catch with the possible ipv4 performance improvment, too. ;)

Thanks,

  Hannes
