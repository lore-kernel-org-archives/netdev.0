From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net: fix /proc/net/dev regression
Date: Tue, 03 Apr 2012 17:25:48 -0400 (EDT)
Message-ID: <20120403.172548.2299885807875686272.davem@davemloft.net>
References: <1333436789.18626.43.camel@edumazet-glaptop>
	<1333441982.18626.62.camel@edumazet-glaptop>
	<4F7B1910.3010701@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	mmaruseac@ixiacom.com
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866Ab2DCVZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 17:25:57 -0400
In-Reply-To: <4F7B1910.3010701@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 03 Apr 2012 08:36:48 -0700

> On 04/03/2012 01:33 AM, Eric Dumazet wrote:
>> Commit f04565ddf52 (dev: use name hash for dev_seq_ops) added a second
>> regression, as some devices are missing from /proc/net/dev if many
>> devices are defined.
>>
>> When seq_file buffer is filled, the last ->next/show() method is
>> canceled (pos value is reverted to value prior ->next() call)
>>
>> Problem is after above commit, we dont restart the lookup at right
>> position in ->start() method.
>>
>> Fix this by removing the internal 'pos' pointer added in commit, since
>> we need to use the 'loff_t *pos' provided by seq_file layer.
>>
>> This also reverts commit 5cac98dd0 (net: Fix corruption
>> in /proc/*/net/dev_mcast), since its not needed anymore.
>>
>> Reported-by: Ben Greear<greearb@candelatech.com>
>> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
>> Cc: Mihai Maruseac<mmaruseac@ixiacom.com>
> 
> This appears to fix the problem.  I do find it mildly irritating
> that the ordering is now random in /proc/net/dev, but I guess
> that is the price of progress.
> 
> Tested-by:  Ben Greear <greearb@candelatech.com>
> 
> Thanks for the quick fix!

Applied, and queued up for -stable, thanks everyone.
