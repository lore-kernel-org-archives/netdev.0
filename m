From: David Miller <davem@davemloft.net>
Subject: Re: IOV iterator bug in net tree
Date: Wed, 01 Jun 2016 17:42:25 -0700 (PDT)
Message-ID: <20160601.174225.2184872288386003765.davem@davemloft.net>
References: <CAKgT0UfZFpUVNHnAjem3yCvf6n-EezqLnZerduQi3jQe76RK7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbcFBAm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 20:42:27 -0400
In-Reply-To: <CAKgT0UfZFpUVNHnAjem3yCvf6n-EezqLnZerduQi3jQe76RK7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 27 May 2016 21:32:39 -0700

> On Fri, May 27, 2016 at 11:21 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> I started out this morning by trying to run DevStack on the latest
>> "net' kernel and it looks like I am hanging on some sort of locking
>> problem with RabbitMQ.  Specifically I am seeing one CPU jump to 100%
>> with perf showing that I am spinning on a lock.
>>
>> I'm working to bisect it now, but just thought I would put it out
>> there if anybody had already root caused this issue.  Below is a few
>> traces to the spin lock call on the spinning CPU:
> 
> I misread the perf trace.  I wasn't spinning on a lock I was spinning
> on the IOV iterator.  It just happened to push the lock to the top of
> the perf trace.  I bisected it down to the recent change in
> iterate_and_advance which was already fixed in Linus's tree in commit
> 19f18459330f "do 'fold checks into iterate_and_advance()" right'.

Since I resynced both of my trees with Linus's, this should be resolved
now, right?
