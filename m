From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCHv6 net-next 1/3] sunvnet: upgrade to VIO protocol version 1.6
Date: Mon, 22 Sep 2014 09:40:30 -0700
Message-ID: <66DC863F-29C0-4E39-AFBE-37C7EA29AA6D@oracle.com>
References: <541A2316.5010603@oracle.com> <2AB76E42-C12D-47C5-8476-0D0C611691A5@oracle.com> <541AD838.50700@oracle.com> <9BA1705F-0C89-471A-9872-688A3FA3165C@oracle.com> <541B395D.1000809@oracle.com> <541FA83B.2050608@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18375 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538AbaIVQki convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 12:40:38 -0400
In-Reply-To: <541FA83B.2050608@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 21, 2014, at 9:40 PM, David L Stevens <david.stevens@oracle.com> wrote:

> 
> 
>> On 09/18/2014 02:49 PM, Raghuram Kothakota wrote:
> 
>>> In the virtualization world, we want resources to be efficiently used and memory is
>>> still very important resource. My concern is mostly because this memory usage of
>>> 32+MB is on a per LDC basis. LDoms today supports a max of 128 domains, but
>>> from my experience seen actual deployments of the order of 50 domains. This is
>>> going up as the platforms getting more and more powerful.  If there are really
>>> that many peers,  then the amount of memory consumed by one vnet instance
>>> is 50 * 32+MB = 1.6GB+.  It's fine if this memory is really used, but it seems like this
>>> will be useful only when the peer is another linux guest with this version of vnet and
>>> also the MTU is configured to use 64K.  The memory is being wasted for all other
>>> peers that either don't support 64K MTU or not configured to use it and also 
>>> the switch port as obviously it doesn't support 64K MTU today.
> 
> I think I have a solution for this -- I'm doing some experimenting, but it may be a few days.
> 
> However, fundamentally, the problem is that there are n^2-n links both ways, so 50 LDOMs on the same vswitch
> will always be 2450X the resources of a single pair, and lead to scary aggregate numbers. Large installations
> really need more vswitches with fewer LDOMs per switch, at least with the current code.

My example is certainly an extreme case, we introduced an option to
disable these inter-vnet-links mainly due to this explosion of LDC usage.
We advise customers to disable the inter-vnet-links when they see the
need to create a large number of vnets in a given vswtich, typically it is
the case with management networks.
We are also looking to automatically disabling these links when we detect more
vnets(probably >16) in a given vswitch.

-Raghuram
> 
> 								+-DLS
