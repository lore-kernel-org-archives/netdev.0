From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] netdev_ops
Date: Fri, 11 Jul 2003 12:51:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0F153C.4040506@candelatech.com>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk> <3F0B2D30.4020102@candelatech.com> <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk> <20030708.150835.78728697.davem@redhat.com> <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk> <20030711193215.GH16037@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com,
   "David S. Miller" <davem@redhat.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030711193215.GH16037@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Comments:
> 
> 1) The _ops are either too limited in scope, or too wide in scope.
> 
> We have a bunch of function pointers in struct net_device.
> We are adding a bunch more func ptrs in a new struct foo_ops.
> 
> If it is called ethtool_ops, I can support the addition of
> 	struct ethtool_ops *etops;
> to struct net_device.
> 
> However, if we call it netdev_ops, the structure's name no longer
> describes its purpose.  If we call it netdev_ops, we should move ALL the
> function pointers in struct net_device into netdev_ops as well, and deal
> with the associated driver breakage.
> 
> So, either change the name back to ethtool_ops, or go all the way.
> The current name to me implies a job half-done.
> 
> Personally, I would prefer the more radical "move all funcptrs into
> netdev_ops".  This is closer to other Linux kernel APIs.

Either way, I'd vote for netdev_ops, because I want to add generic
'ioctls' that work on struct net_device, not necessarily just ethernet
devices.  However, it's a minor issue since the code will work
regardless.

> 3) The func ptrs _count() are totally bogus.  We have an unconditional
> indirect reference to a function call which does nothing but return a
> driver constant.
> 
> I personally think that having ethtool_ops members manually calling
> the ->get_drvinfo hook is a _lot_ cleaner than 10,000 foo_count hooks.
> 
> 3.a) Further, we will inevitably be adding more counts in the future.
> If we wanted to be truly expandable, and you really don't like the
> counts being in struct ethtool_gdrvinfo, then create a struct
> ethtool_counts that puts all the constants in one place.

Suppose we do this, how will we make a user-space app that tries to
read this be backwards/forwards compatible?  This is one of the reasons
I was hoping for some versioning information that could be probed at
run-time from user-space.  Could bump the version each time we change
something that is difficult to detect in user-space.  (ie, adding a
new ethtool-cmd is easy to detect because we'll get EINVAL or something
when it's not there, and a success when it is, but getting a different
sized struct, or a struct who's members have changed their meaning, will
be more difficult to detect I believe.)

Programs that do not wish to deal with the cruft of versioning can just
ignore it, but ones that are designed to be very robust can do the extra
work to deal with the different versions.


> 
> 
> 4) I don't see why ethtool.h suddenly needs to include linux/types.h,
> when it hasn't needed it in all this time until now.

If we're changing lots of stuff...it would be nice to change the u32
etc to something that user-space can easily handle, as ethtool.h is
(for better or worse) being included from user-space.  Minor issue
again as it can be dealt with via type-defs etc.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
