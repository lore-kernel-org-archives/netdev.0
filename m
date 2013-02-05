From: Paul Clements <paul.clements@us.sios.com>
Subject: Re: [PATCH] NBD: Move from a global spinlock to one lock per NBD device
Date: Tue, 5 Feb 2013 16:31:16 -0500
Message-ID: <CAECXXi6CLm=tOKGfq1pu5s5dSsXQc8BCpnzx-fSAaFGsUauqUg@mail.gmail.com>
References: <1359993343.18869.14.camel@eboracum.office.bytemark.co.uk>
	<CAPshTCir48mTze-pEayg5TDxcH0Tyi4=NoH-FBhnM4rgrxekfQ@mail.gmail.com>
	<1360080867.18869.30.camel@eboracum.office.bytemark.co.uk>
	<20130205162248.GG20842@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Nicholas Thomas <nick@bytemark.co.uk>, jaxboe@fusionio.com,
	netdev@vger.kernel.org, hkchu@google.com, davem@davemloft.net,
	eric.dumazet@gmail.com
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:56093 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756819Ab3BEVhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 16:37:48 -0500
Received: by mail-vc0-f176.google.com with SMTP id fy27so390612vcb.21
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 13:37:47 -0800 (PST)
In-Reply-To: <20130205162248.GG20842@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 5, 2013 at 11:22 AM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> On Tue, Feb 05, 2013 at 04:14:27PM +0000, Nicholas Thomas wrote:
>> This patch is entirely based on a submission by Jerry Chu, incorporating
>> suggestions from Eric Dumazet. Modern, faster NICs make the original comment
>> on why a single lock is preferable incorrect; moving to one lock per NBD
>> device removes a performance bottleneck.
>>
>> Original patch: http://permalink.gmane.org/gmane.linux.network/207233
> ...
>> +static spinlock_t *nbd_locks __read_mostly;
> ...
>
> This is about the worst way to split up a lock possible.  Most (all?) of the
> spinlocks across nbd devices are on the same cacheline, so performance will
> be limited by the rate of cacheline bounces for the lock.  It would be far
> better to embed the spinlock in the data structures that it will be
> protecting to avoid this expensive false-sharing.

Yes, embedding this in the nbd_device would be much better, no?

--
Paul
