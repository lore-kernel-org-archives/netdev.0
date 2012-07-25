From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Wed, 25 Jul 2012 16:39:39 -0700 (PDT)
Message-ID: <20120725.163939.581743307449189972.davem@davemloft.net>
References: <20120720.142502.1144557295933737451.davem@davemloft.net>
	<CAKgT0UdcqE52WFCT-t2om0SN3Yq5GqiwN+JbwCcnBv4LDOB6BQ@mail.gmail.com>
	<20120725.161732.91008692477078715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab2GYXjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 19:39:40 -0400
In-Reply-To: <20120725.161732.91008692477078715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 25 Jul 2012 16:17:32 -0700 (PDT)

> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Wed, 25 Jul 2012 16:02:45 -0700
> 
>> Since your patches are in I have started to re-run my tests. I am
>> seeing a significant drop in throughput with 8 flows which I expected,
>> however it looks like one of the biggest issues I am seeing is that
>> the dst_hold and dst_release calls seem to be causing some serious
>> cache thrash.  I was at 12.5Mpps w/ 8 flows before the patches, after
>> your patches it drops to 8.3Mpps.
> 
> Yes, this is something we knew would start happening.
> 
> One idea is to make cached dsts be per-cpu in the nexthops.

Actually I think what really kills your case is the removal of the
noref path for route lookups.  I'll work on a patch to restore that
in the case where we use cached routes from the FIB nexthops.
