From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] ethernet: use core min/max MTU checking
Date: Tue, 18 Oct 2016 11:33:27 -0400 (EDT)
Message-ID: <20161018.113327.621225542297731341.davem@davemloft.net>
References: <20161017195417.48259-1-jarod@redhat.com>
        <20161017.160341.529517225075047124.davem@davemloft.net>
        <20161017202943.GP14983@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017202943.GP14983@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Mon, 17 Oct 2016 16:29:43 -0400

> On Mon, Oct 17, 2016 at 04:03:41PM -0400, David Miller wrote:
>> From: Jarod Wilson <jarod@redhat.com>
>> Date: Mon, 17 Oct 2016 15:54:02 -0400
>> 
>> > For the most part, every patch does the same essential thing: removes the
>> > MTU range checking from the drivers' ndo_change_mtu function, puts those
>> > ranges into the core net_device min_mtu and max_mtu fields, and where
>> > possible, removes ndo_change_mtu functions entirely.
>> 
>> Jarod, please read my other posting.
> 
> Done, didn't see it until just after I'd hit send, have replied there as
> well.
> 
>> You've positively broken the maximum MTU for all of these drivers.
>> 
>> That's not cool.
>>
>> And this series fixing things doesn't make things better, because now
>> we've significanyly broken bisection for anyone running into this
>> regression.
> 
> Agreed, and my suggestion right now is to revert the 2nd patch from the
> prior series. I believe it can be resubmitted after all other callers of
> ether_setup() have been converted to have their own min/max_mtu.
> 
>> You should have arranged this in such a way that the drivers needing
>> > 1500 byte MTU were not impacted at all by your changes, but that
>> isn't what happened.
> 
> Yeah, I must admit to not looking closely enough at the state the first
> two patches left things in. It was absolutely my intention to not alter
> behaviour in any way, but I neglected to test sufficiently without this
> additional set applied.

So what I'm going to do now it simply just apply your current patch series
to net-next and hope this gets everything working again.

I'm just happy that you acknowledged how badly things got broken, so let's
move on and try to avoid this happening again in the future.

Thanks.
