From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Tue, 20 Dec 2016 13:28:13 -0500 (EST)
Message-ID: <20161220.132813.435056880928769245.davem@davemloft.net>
References: <20161220004013.43pcopemc6im32az@codemonkey.org.uk>
        <20161219.203623.119653805184192345.davem@davemloft.net>
        <20161220181728.dd2cynjwrceruwcu@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42910 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764493AbcLTS2R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 13:28:17 -0500
In-Reply-To: <20161220181728.dd2cynjwrceruwcu@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Tue, 20 Dec 2016 13:17:28 -0500

> On Mon, Dec 19, 2016 at 08:36:23PM -0500, David Miller wrote:
>  > From: Dave Jones <davej@codemonkey.org.uk>
>  > Date: Mon, 19 Dec 2016 19:40:13 -0500
>  > 
>  > > On Mon, Dec 19, 2016 at 07:31:44PM -0500, Dave Jones wrote:
>  > > 
>  > >  > Unfortunately, this made no difference.  I spent some time today trying
>  > >  > to make a better reproducer, but failed. I'll revisit again tomorrow.
>  > >  > 
>  > >  > Maybe I need >1 process/thread to trigger this.  That would explain why
>  > >  > I can trigger it with Trinity.
>  > > 
>  > > scratch that last part, I finally just repro'd it with a single process.
>  > 
>  > Thanks for the info, I'll try to think about this some more.
> 
> I threw in some debug printks right before that BUG_ON.
> it's always this:
> 
> skb->len=31 skb->data_len=0 offset:30 total_len:9
> 
> Shouldn't we have kicked out data_len=0 skb's somewhere before we got this far ?

skb->data_len is just the length of any non-linear data in the SKB.

This has to do with the SKB buffer layout and geometry, not whether
the packet is "fragmented" in the protocol sense.

So no, this isn't a criteria for packets being filtered out by this
point.

Can you try to capture what sk->sk_socket->type and
inet_sk(sk)->hdrincl are set to at the time of the crash?

Thanks.
