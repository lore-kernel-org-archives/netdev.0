From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 14:00:13 -0700 (PDT)
Message-ID: <20120726.140013.203868407338083397.davem@davemloft.net>
References: <1343323858.2626.11783.camel@edumazet-glaptop>
	<1343324175.2626.11790.camel@edumazet-glaptop>
	<1343324633.2626.11801.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161Ab2GZVAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 17:00:14 -0400
In-Reply-To: <1343324633.2626.11801.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Jul 2012 19:43:53 +0200

> On Thu, 2012-07-26 at 19:36 +0200, Eric Dumazet wrote:
>> On Thu, 2012-07-26 at 19:31 +0200, Eric Dumazet wrote:
>> > On Thu, 2012-07-26 at 10:18 -0700, Alexander Duyck wrote:
>> > 
>> > > I tested this patch and it looks like it runs, but still has the same
>> > > performance issue.  I did some digging into the annotation for
>> > > ip_route_intput_noref and it seems like the issue is that I am hitting
>> > > the dst_hold call in  __mkroute_input.
>> > 
>> > David suggested a percpu cache.
>> > 
>> > nh_rth_input would be allocated by alloc_percpu(struct dst *)
>> > 
>> > I can work on this.
>> 
>> Wait a minute, on input we should use the noref trick too.
>> 
> 
> Something like : (on top of latest David patch)

Grrr, I only got the local routes didn't I? :-)

That would explain everything.
