From: Ben Greear <greearb@candelatech.com>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Wed, 06 Nov 2002 13:30:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DC98A10.5030407@candelatech.com>
References: <3DC8B85B.5050805@candelatech.com>	<15817.21170.173913.829498@robur.slu.se>	<3DC95631.6030001@candelatech.com> <15817.29109.859144.565330@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Ben Greear writes:

>  I still doubt ;-) 
> 
>  With e1000 I played with various settings for RX-buffers rather recently 
>  when the 82544 increased the number of available buffers from 256 to 4096.
> 
>  And I guess my test looks a bit like yours... Injecting an "overload" of 
>  packets. I found was 256 buffers was the optimum. Approximative of course.

It's possible that it is a particular issue with my NICs (Old Phobos 4-port).
Phobos folks said the bridge chipset has errata that make it un-suitable for
high speeds.  And something about a memory divide-by-four error.  It may be
that the extra buffers help hide the hardware defects in some manner.
I was, for instance, seeing cases where packets just dissappeared...and no
error counters were being bumped.

With the latest kernel drivers, the 570tx NIC seems to have
trouble autonegotiating full-duplex again, so I have not been testing
with it lately (I think it uses the same bridge chipset anyway.)

I will try changing around those numbers again now that I have a baseline
to work from.

>  And as you saw for SMP with recycle it is easy to feed the recycled skb 
>  back to CPU were it was created/processed.

Yes, I can see how that would be useful on SMP, so there may be less gain
for single-proc systems.  I actually am pretty fuzzy on cache-line optimizations
and the like...


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
