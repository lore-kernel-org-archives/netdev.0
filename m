From: Ben Greear <greearb@candelatech.com>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Wed, 06 Nov 2002 09:49:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DC95631.6030001@candelatech.com>
References: <3DC8B85B.5050805@candelatech.com> <15817.21170.173913.829498@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
   Jeff Garzik <jgarzik@mandrakesoft.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Ben Greear writes:
>  > Here is a patch that makes Tulip support NAPI.  The vast bulk of these
>  > changes come from Robert Olsson's ftp site, I just pieced them together.
>  > 
>  > It works good on my 4-port Tulip NICs, better than the default
>  > driver at least (no, I never tried the old HW-Mitigation option).
>  > 
>  > This patch will also make use of Robert's skb-recycle patch if it's
>  > been applied, but through #ifdef magic, it should also work w/out
>  > that....
> 
>  Hello!
> 
>  Well skb recycling is "research" and should be used to challange to vm/slab
>  people to start with... And I guess you will get objections about the extra 
>  stats as well.

The stats stuff is #ifdef'd out, as is the skb-recycling stuff.

> 
>  I see you increased the RX-ring to 1024 pkts. 
>  Did you really see any improvement with this?

It helped drop fewer packets when running 4 ports at 92Mbps+
However, the difference between that and 512 is not large.
I would really like to make that size adjustable at module load
time and/or runtime, but I'm not sure how easy that would be.

Imagine being able to crank up your receive buffers when running at
very high speeds (and/or when you start dropping packets).  At lower speeds,
shrink things down and free up resources....


>  Also I would be interested if you have any numbers for recycling patch? 

I still need to do some comparisons with that being the only difference.
I do know that it does not appear to hurt anything, but it's also possible
that it doesn't really help.  Since under normal circumstances there are
enough buffers to be allocated with GFP_ATOMIC, I believe that it will take
long statistical runs to determine if this really helps.  I do like very
much the fact that it actually gives me something deterministic to tune though,
so I'll keep it for that reason if nothing else.

>  Jamal and I spent some days after OLS to test and tune but it wasn't to 
>  promising at that time but it's reworked now.

Were you testing SMP or uni-processor?  I've been doing the tulip testing
on a single processor P-IV system.

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
