From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  Break 'budget' dependency on netdev_max_backlog.
Date: Tue, 22 Oct 2002 20:43:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB61AC4.4070907@candelatech.com>
References: <Pine.GSO.4.30.0210222317210.24323-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Tue, 22 Oct 2002, Ben Greear wrote:
> 
> 
>>Think we should add an IOCTL to change the weight of a device
>>dynamically?  (I want my e1000 and tg3 to have higher weight than
>>the tulip nics, I imagine)
>>
>>Is there a ready-built proc interface to do things to individual devices?
>>
> 
> 
> tulip hardcodes it; net/core/dev.c::weight_p is supposed to be the general
> one and is proc settable via NET_CORE_DEV_WEIGHT; only problem is that
> is not shadowed by the devices.
> I am not sure if ioctls or module parameters are the best way to override
> the default weight_p value. Somehow we need something to set this value.

No reason not to provide both!  The IOCTL can take care of any drivers
that don't take module parameters for it, and can do it in a generic
way.

The tulip driver I am poking at hard-coded it to 16.  64 seems to work
just as good.

Any idea (other than trial and error) for how to determine a good value
for this?  Maybe should take the number of active devices into account
and wiggle things dynamically from user-space?

Ben

> 
> cheers,
> jamal
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
