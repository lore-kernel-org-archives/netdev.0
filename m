From: Rik van Riel <riel@surriel.com>
Subject: Re: Possible ways of dealing with OOM conditions.
Date: Sat, 20 Jan 2007 17:36:03 -0500
Message-ID: <45B29953.5010505@surriel.com>
References: <20070117045426.GA20921@2ka.mipt.ru> <1169024848.22935.109.camel@twins> <20070118104144.GA20925@2ka.mipt.ru> <1169122724.6197.50.camel@twins> <20070118135839.GA7075@2ka.mipt.ru> <1169133052.6197.96.camel@twins> <20070118155003.GA6719@2ka.mipt.ru> <1169141513.6197.115.camel@twins> <20070118183430.GA3345@2ka.mipt.ru> <1169211195.6197.143.camel@twins> <20070119225643.GA22728@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-mm@kvack.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imladris.surriel.com ([66.92.77.98]:54159 "EHLO
	imladris.surriel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbXATW6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jan 2007 17:58:49 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20070119225643.GA22728@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Fri, Jan 19, 2007 at 01:53:15PM +0100, Peter Zijlstra (a.p.zijlstra@chello.nl) wrote:

>>> Even further development of such idea is to prevent such OOM condition
>>> at all - by starting swapping early (but wisely) and reduce memory
>>> usage.
>> These just postpone execution but will not avoid it.
> 
> No. If system allows to have such a condition, then
> something is broken. It must be prevented, instead of creating special
> hacks to recover from it.

Evgeniy, you may want to learn something about the VM before
stating that reality should not occur.

Due to the way everything in the kernel works, you cannot
prevent the memory allocator from allocating everything and
running out, except maybe by setting aside reserves to deal
with special subsystems.

As for your "swapping early and reduce memory usage", that is
just not possible in a system where a memory writeout may need
one or more memory allocations to succeed and other I/O paths
(eg. file writes) can take memory from the same pools.

With something like iscsi it may be _necessary_ for file writes
and swap to take memory from the same pools, because they can
share the same block device.

Please get out of your fantasy world and accept the constraints
the VM has to operate under.  Maybe then you and Peter can agree
on something.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.
