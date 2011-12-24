From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netem: dont call vfree() under spinlock and BH disabled
Date: Sat, 24 Dec 2011 16:10:08 -0500 (EST)
Message-ID: <20111224.161008.1932318524459500544.davem@davemloft.net>
References: <1324704531.2915.43.camel@edumazet-laptop>
	<20111224111854.479d497e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54044 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279Ab1LXVKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Dec 2011 16:10:14 -0500
In-Reply-To: <20111224111854.479d497e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 24 Dec 2011 11:18:54 -0800

> On Sat, 24 Dec 2011 06:28:51 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> commit 6373a9a286 (netem: use vmalloc for distribution table) added a
>> regression, since vfree() is called while holding a spinlock and BH
>> being disabled.
>> 
>> Fix this by doing the pointers swap in critical section, and freeing
>> after spinlock release.
>> 
>> Also add __GFP_NOWARN to the kmalloc() try, since we fallback to
>> vmalloc().
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
 ...
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
