From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: fix a potential NULL deref
Date: Mon, 29 Oct 2012 13:22:03 -0400 (EDT)
Message-ID: <20121029.132203.1458595923917658146.davem@davemloft.net>
References: <1351482620-11008-1-git-send-email-amwang@redhat.com>
	<1351491005.7394.7.camel@edumazet-glaptop>
	<1351493366.8221.2.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760318Ab2J2RWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 13:22:05 -0400
In-Reply-To: <1351493366.8221.2.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 29 Oct 2012 14:49:26 +0800

> On Mon, 2012-10-29 at 07:10 +0100, Eric Dumazet wrote:
>> > -		dst_release(&rt->dst);
>> > +		if (rt)
>> > +			dst_release(&rt->dst);
>> >  	}
>> >  
>> 
>> dst_release() is like kfree(), it accepts a NULL argument.
>> 
> 
> 'rt->dst' already dereferences 'rt', no matter dst_release() accepts
> NULL or not.

It's taking the address of a struct member, it's not a dereference.

You know what the difference is right?
