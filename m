From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Wed, 24 Apr 2013 08:05:09 -0700
Message-ID: <1366815909.8964.70.camel@edumazet-glaptop>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
	 <1366373950.26911.134.camel@localhost>
	 <1366382991.16391.6.camel@edumazet-glaptop>
	 <1366810523.26911.495.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:46756 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756837Ab3DXPFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 11:05:12 -0400
Received: by mail-pd0-f172.google.com with SMTP id 4so1197610pdd.3
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 08:05:11 -0700 (PDT)
In-Reply-To: <1366810523.26911.495.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 15:35 +0200, Jesper Dangaard Brouer wrote:
> On Fri, 2013-04-19 at 07:49 -0700, Eric Dumazet wrote:

> > Thats pretty irrelevant, memory is limited by the total amount of memory
> > used by fragments, not by hash table size.
> >
> > Its called /proc/sys/net/ipv4/ipfrag_high_thresh
> 
> 
> I was talking about patch-03, where I do "direct hash cleaning", and
> have moved the mem limit "ipfrag_high_thresh" into the hash cleaning
> step.

I am fine to remove LRU, as maintaining a LRU is too expensive and this
LRU has little purpose.

Old frags are evicted anyway because they have a timer.

We have to keep a global limit, especially if we increase hash table
size, because even with perfect hashing and one frag per hash slot we
might consume too much ram.

We can rename it if you wish but currently this is ipfrag_high_thresh.
