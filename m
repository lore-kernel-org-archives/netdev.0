From: Ben Greear <greearb@candelatech.com>
Subject: Re: netdev_ops?
Date: Wed, 23 Jul 2003 01:08:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F1E4290.6020303@candelatech.com>
References: <3F1E17BC.30100@candelatech.com>	<20030722220745.379a73c6.davem@redhat.com>	<3F1E1D62.90009@candelatech.com>	<20030722230215.284dd270.davem@redhat.com>	<3F1E2A00.5080506@candelatech.com>	<20030722232719.216d7823.davem@redhat.com>	<3F1E2CE9.2080404@candelatech.com>	<20030723000130.3a6a917e.davem@redhat.com>	<3F1E391B.80209@candelatech.com> <20030723003439.684de751.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030723003439.684de751.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 23 Jul 2003 00:28:27 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>In my case, if the net_device can return net_device_stats, then I want it to work.
> 
> 
> This is not for you to decide.  That is the driver author's
> choice.

Is it their choice to participate in the /proc/net/dev output?
I want the same info, only in binary format.  However, this is
a side issue:  I am really looking for a flexible way to add new
features through some ioctl interface, and these features will
act primarily on struct net_device, ie at an abstract layer and
independent of the underlying driver.

> Also, succeeding for _ANY_ ethtool command is going to give
> a tool the impression that other basic ethtool commands should
> work too.  Your patch makes many devices give very inconsistent
> behavior.

Only stupid tools...every use of ETHTOOL has to be checked because
every driver implements different portions, or none at all.  Inconsistent
is when ethtool eth0 works when eth0 happens to be an 8139too
driver and fails when eth0 is a tulip driver.

> The correct "fix" on the 2.4.x side is to add the appropriate ethtool
> support to appropriate drivers that lack it and need this interface.
> It is not your hack and it is not adding a new ioctl.

So, you'd accept an identical 30 line patch to *every* network
device driver?  And what about the ones that support no ethtool
at all...would you accept the patch that only supported getting the
binary stats?

> You still haven't said why parsing /proc/dev is so bad, and you
> even admit that your tool has to fall back to this ANYWAYS.

I notice slowness when trying to probe 250 interfaces (vlans)
very often.  And no wonder, considering that to get up to date
stats I need to read all of /proc/net/dev, search for the right line,
and then parse it.  Of course my tool will fall back:  I want it
to work everywhere...but that doesn't mean it shouldn't run better
on newer kernels.

> 
> My final note:  You don't even have the problem you claim to have.
>                 Use your brain and 'grep' a little bit, ok? :-)
> 
>                 egrep get_stats net/core/rtnetlink.c
> 
>                 There it is, exactly what you need and supported on
>                 every single kernel out there.

Yep, I looked through that..and through libnetlink, and the complexity
is not worth it.  Besides, I have multiple other things that are common
to all ethernet and ethernet-like devices, so I need to either add IOCTLs,
proc interfaces, or hack ethtool.  I can continue to ship my own kernel
and/or provide patches, but I would prefer to get the support into the mainline
kernel.  If you have ideas for how you'd like to see this done, plz tell.
If you will never accept such a thing, then I'll ask again in 6 months
and hope someone else answers.


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
