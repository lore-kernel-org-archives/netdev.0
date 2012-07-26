From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 13:59:11 -0700 (PDT)
Message-ID: <20120726.135911.1092802163856239928.davem@davemloft.net>
References: <1343291278.2626.11188.camel@edumazet-glaptop>
	<20120726.014736.1066206957795563053.davem@davemloft.net>
	<CAKgT0UfYEBYQOAoZ77rtwctbwau=2kx4rYdTyeaPaipeMUP9aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269Ab2GZU7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 16:59:14 -0400
In-Reply-To: <CAKgT0UfYEBYQOAoZ77rtwctbwau=2kx4rYdTyeaPaipeMUP9aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 26 Jul 2012 10:18:03 -0700

> I did some digging into the annotation for ip_route_intput_noref and
> it seems like the issue is that I am hitting the dst_hold call in
> __mkroute_input.

We shouldn't be building any routes in __mkroute_input except for the
very first packet, we should be instead using the cached route in the
FIB info nexthop.

Something's not right.
