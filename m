From: Ben Greear <greearb@candelatech.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 18:15:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE682B8.8060708@candelatech.com>
References: <20030610.152020.59678979.davem@redhat.com>	<Pine.LNX.4.51.0306101956520.7801@ns.istop.com>	<3EE67D2D.80608@candelatech.com> <20030610.180120.71112140.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
In-Reply-To: <20030610.180120.71112140.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Ben Greear <greearb@candelatech.com>
>    Date: Tue, 10 Jun 2003 17:51:57 -0700
>    
>    Maybe as a configurable option, since it would make tcpdump less useful.
>    Seems like we could kludge it up so that we used the TSC (or whatever that
>    really fast hardware clock is) to provide some relative stamp that could be
>    converted to a time_val later?
> 
> I have a strange feeling that Ralph's system isn't using
> TSC and that's why it shows up so high on the profiles :-)
> TSC do_gettimeofday() is REALLY cheap (TSC read plus a multiply which
> x86 does in like 5 cycles).
> 
> Yes, this idea has been tossed around before.  But what's funny
> is that on the bigger boxes, you don't use TSC because amongst
> the different nodes of the machine they are skewed, so you have
> to use the ACPI timer or something like that for timestamping.

What determines whether or not we use the "TSC do_gettimeofday".  Does
it automagically happen when you compile for P-III or something like
that?

And how big of a "bigger box" are you talking about...regular old SMP, or NUMA?

>    
>    It does seem a bit wasteful to do the gettimeofday when most of the time
>    the result is ignored.
>    
>    (Or, are there things other than tcpdump that need the gettimeofday stamp?)
> 
> SO_RECVSTAMP, any socket on the machine can ask for this.

Do we know when we are being asked for this value?  Ie, could we do the
TSC/ACPI timer -> time_val conversion here?  If TSC means cheap gettimeofday
anyway, then my last question is moot.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
