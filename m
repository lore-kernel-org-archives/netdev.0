From: Ben Greear <greearb@candelatech.com>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond
 interfaces
Date: Mon, 12 Jan 2004 09:23:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4002D826.3080409@candelatech.com>
References: <200401081819.54484.amir.noam@intel.com> <4000A838.5040808@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Noam <amir.noam@intel.com>, Jay Vosburgh <fubar@us.ibm.com>,
        bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4000A838.5040808@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Amir Noam wrote:
> 
>> The following patch sets provide basic support for future bonding 
>> operations (specifically for dynamic configuration of bonding 
>> interfaces).
>>
>> This is done by adding two new bonding ioctls: one for deviceless 
>> commands (an ioctl hook) and one for device oriented commands. Like 
>> ethtool, the first u32 value in the data structure will indicate the 
>> exact sub-command to be executed.
>>
>> The sets are against the latest netdev-2.4 and net-drivers-2.5-exp trees.
> 
> 
> 
> I don't disagree with the overall goal of these patches, but I think we 
> might need to pause a bit, and consider how best to configure, add, and 
> remove bonding interfaces, if we are coming up with a new interface.
> 
> For configuration tasks that occur outside the scope of a single bonding 
> interface (i.e. a single struct net_device), you need a separate entity 
> from a socket ioctl.  It's not ideal at all to configure N objects using 
> a special ioctl ... when opening one of said objects :)

Why is it not ideal?  Are ioctl calls significantly less expensive
than accessing a character device?  It does not seem easier to program
on either side, and wouldn't users have to do a mknod or something like
that to get their char device to appear?

I would not look forward to dealing with framing issues in the kernel
either, and for 'reading' information, it seems there could be some tricky
code dealing with queueing up the message for user-space and then *hoping*
that they did a 'read' before you had to clean up the message and/or
over-write it.

> I would suggest a simple character device (misc_register), and let the 
> userland application configure settings unrelated to a single object.
> 
> For a configuring state related to a _single_ bonding interface (i.e. a 
> single net_device), socket ioctls are OK.

 From a user-space coding perspective, it would be easier to just have
one socket to do all the ioctl calls.  I really don't see even an aesthetic
reason to artificially restrict an socket ioctl to only function on a single
thing.

Please don't tell me you also want to change ethtool to not use
multiplexed ioctl calls as it does now?  (I like the ethtool interface
very much and in fact, if I were starting over, I'd implement VLAN
ioctls as an ethtool command...)


Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
