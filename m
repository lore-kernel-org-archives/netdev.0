From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond
 interfaces
Date: Mon, 12 Jan 2004 21:34:06 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4003591E.5050906@pobox.com>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com> <200401111628.07930.amir.noam@intel.com> <4001A667.2020904@pobox.com> <4001C158.6040103@candelatech.com> <4001C72E.8030108@pobox.com> <slrnc03pm8.3sp.lunz@orr.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <slrnc03pm8.3sp.lunz@orr.homenet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> jgarzik@pobox.com said:
> 
>>The key question is what is the best interface for userland to configure 
>>in-kernel information -that is unrelated to a specific interface-. 
>>ethtool ioctl space doesn't apply, because that's a per-interface API.
> 
> 
> ethtool is just as bad as brctl or any of the others. From (userland)
> ethtool.c:

ethtool contains only per-interface operations.

One should not stuff extra-interface operations onto an ioctl, IMO.


> calling a spade a spade, and all that. I don't see how that's any better
> than brctl. The per-interface only comes into it when you copy a dev
> name into a struct ifreq, but that doesn't associate the fd with the
> interface in any way. You could go ahead and issue another ioctl on the
> same fd for a different interface. 

I make it no secret that I dislike ioctls in general, and would like to 
move away from dependence on ioctl (and procfs) magic...  Ideally one 
should be able to maintain and coordinate the ABI of one's own driver, 
without always going through a central authority for some magic number. 
  Linux is (should be) more dynamic than that.  It's a hotplug, 
decentralized world :)

	Jeff
