From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/802/mrp: fix lockdep splat
Date: Tue, 14 May 2013 13:03:07 -0700 (PDT)
Message-ID: <20130514.130307.629850895919092156.davem@davemloft.net>
References: <20130514.120754.1745967383330029903.davem@davemloft.net>
	<1368559307.4519.21.camel@edumazet-glaptop>
	<1368560401.4519.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, amwang@redhat.com, david.ward@ll.mit.edu,
	hayeswang@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376Ab3ENUDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 16:03:12 -0400
In-Reply-To: <1368560401.4519.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 May 2013 12:40:01 -0700

> On Tue, 2013-05-14 at 12:21 -0700, Eric Dumazet wrote:
>> On Tue, 2013-05-14 at 12:07 -0700, David Miller wrote:
>> 
>> > Can you double check that you really had Eric's patch applied?
>> > lockdep appears to be complaining about the same thing in your
>> > log dump, as if the patch was not really applied.
>> > 
>> > It's saying that app->lock can be taken from the join timer in
>> > softirq, but mrp_uninit_applicant() takes it without disabling
>> > softirqs.
>> > 
>> > Eric's patch explicitly fixes this, by making sure that spin_lock_bh()
>> > is used there.
>> 
>> I am going to test this myself, it seems quite simple.
>> I'll add a Tested-by: tag once done.
> 
> I definitely could trigger the bug easily without my patch :
 ...
> And with the patch, there is no lockdep splat anymore.
> 
> Tested-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
