From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET is
 enabled
Date: Tue, 03 Nov 2015 10:33:19 -0500 (EST)
Message-ID: <20151103.103319.1465681990237533576.davem@davemloft.net>
References: <1446398459.6254.90.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151101.155859.1206189858863918018.davem@davemloft.net>
	<BY2PR0301MB16547E3AA4FB1F1AC8DE28ECA02B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, haiyangz@microsoft.com,
	edumazet@google.com, netdev@vger.kernel.org
To: kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44556 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851AbbKCPdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 10:33:24 -0500
In-Reply-To: <BY2PR0301MB16547E3AA4FB1F1AC8DE28ECA02B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: KY Srinivasan <kys@microsoft.com>
Date: Tue, 3 Nov 2015 07:59:36 +0000

> I have implemented the scheme we had discussed a few weeks ago. In
> this new implementation our driver is NOT requesting addition
> headroom - rndis header and the per packet state is being maintained
> outside of the skb. What I am seeing is that when I have
> LL_MAX_HEADER set to 220 bytes, even though our driver is not using
> the additional head room, I see about a 10% boost in the peak
> performance (about 34 Gbps on a 40Gbps interface). However, when I
> set the LL_MAX_HEADER value to the current default, the peak
> performance drops back to what we currently have (around 31
> Gbps). In both these cases, there is no reallocation of skb since no
> additional headroom is being requested and yet there is a
> significant difference in performance.  I trying to figure out why
> this is the case, your insights will be greatly appreciated.

It probably has something to do with cache line or data alignment.
