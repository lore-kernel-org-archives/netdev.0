From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression from routing cache removal?
Date: Wed, 05 Jun 2013 13:52:15 -0700
Message-ID: <1370465535.24311.304.camel@edumazet-glaptop>
References: <20130605175724.GA2576@sbohrermbp13-local.rgmadvisors.com>
	 <1370455997.24311.290.camel@edumazet-glaptop>
	 <20130605203253.GB2576@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:46214 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757317Ab3FEUwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 16:52:17 -0400
Received: by mail-pa0-f52.google.com with SMTP id bg2so1234260pad.25
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 13:52:16 -0700 (PDT)
In-Reply-To: <20130605203253.GB2576@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 15:32 -0500, Shawn Bohrer wrote:

> Indeed it does.  So what are my options here?
> 
> 1) Use fewer multicast addresses.  This may not be possible since in
> some cases I don't control the incoming data/addresses.  I am running
> a test sending the same data over ~280 vs 350 and naturally it does
> appear to be better.
> 
> 2) Make that linear scan a hash lookup?  Are there any downsides or
> reasons not to do this?
> 

It can be easily done, with a threshold : 

Above say 4 multicast addresses in the mc_list, allocate a hash table
and populate it.

Nice thing is that this hash table could be dynamically reallocated,
instead of being of fixed size, as we would keep the mc_list as well.

> 3) ?

One idea would be to extend IP early demux, currently handling only TCP
sockets, to UDP sockets.

This would work if you have no more than one socket receiving traffic to
a particular address:port, and this would avoid IP fib/dst stuff, as the
socket would have a cache of the dst.
