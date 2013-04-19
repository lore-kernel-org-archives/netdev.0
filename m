From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Fri, 19 Apr 2013 07:49:51 -0700
Message-ID: <1366382991.16391.6.camel@edumazet-glaptop>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
	 <1366373950.26911.134.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:42397 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030593Ab3DSOtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 10:49:53 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa11so2326238pad.27
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 07:49:53 -0700 (PDT)
In-Reply-To: <1366373950.26911.134.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 14:19 +0200, Jesper Dangaard Brouer wrote:

> When removing the LRU system (which is the real bottleneck, see perf
> tests in cover mail), and doing direct hash cleaning we are trading-in
> accuracy.
> 

You are mixing performance issues and correctness.

> The reason I don't want a too big hash table is the following.
> 

> Worst case 1024 buckets * 130K bytes = 133 MBytes, which on smaller
> embedded systems is a lot of kernel memory we are permitting a remote
> host to "lock-down".

Thats pretty irrelevant, memory is limited by the total amount of memory
used by fragments, not by hash table size.

Its called /proc/sys/net/ipv4/ipfrag_high_thresh

It seems you me you are spending time on wrong things.
