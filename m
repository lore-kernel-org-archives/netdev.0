From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 15:05:17 -0400
Message-ID: <20090312190517.GD24995@hmsreliant.think-freely.org>
References: <49B82566.3070909@weinigel.se> <20090311171354.04c7a63d@nehalam> <49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net> <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312174933.GC24995@hmsreliant.think-freely.org> <49B95386.2030600@weinigel.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Christer Weinigel <christer@weinigel.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45257 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902AbZCLTFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:05:39 -0400
Content-Disposition: inline
In-Reply-To: <49B95386.2030600@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 07:25:10PM +0100, Christer Weinigel wrote:
> Neil Horman wrote:
>> You don't need klibc, you can use regular glibc, and even build statically if
>> you like.  You'll have to use dig or host to do name lookups, but thats also
>> pretty easy to do.  This really is easier than you think it is :)
>
> Size, size, size.  The killer in the embedded world which rules out  
> glibc.  And have you tried to link glibc statically with something that  
> uses gethostbyname lately?  It is no longer possible since the  
> introduction of all the introduction of the dynamic name lookup crap  
> (ok, it's not really crap, I just feel like it's crap every time I try  
> to link a networking application statically).  But that's a bit off  
> topic since I don't need name lookups just to mount a NFS file system.  
> uclibc also seems to have issues with networking and statically linked  
> binaries, but I just haven't had time to figure out why yet.
>

You didn't read what I wrote very closely, I specifically said you have to dig
or host to do name lookups, specifically because of the issues with getXbyY.
When I said I built busybox in 800k (400k compressed), That was with glibc
statically linked.  End of story.  You're making up problems here, its not that
big a deal.  I've not looked at the figures lately, but how much space does the
dhcp client and nfs root code take up in the kernel these days?  I imagine that
what you save there by turning those off will be a good start in offsetting the
space you need for an initramfs.

>> Well, you've said it there yourself.  What you're proposing is a hack in the
>> driver.  This really isn't the place for hacks.  This is the place for doing
>> things in as consistent and maintainable a way as possible.  
>
> In my opion, having a "hwaddrs=eth0=00:de:ad:be:ef:01" would be  
> consistent and maintainable.  But opinions differ.
>
I never said you can't still use that command line option to implement this
solution, you just have to parse it in userspace.

>> You're last comment is in direct contradiction to what you are saying here.  As
>> you've discovered, the in kernel dhcp and nfs root client are useless unless
>> your ethernet interface has a mac on it, and if you don't have a mac stored in
>> eeprom that the driver can access, you can't assign one without introducing a
>> big hack, which no one here is going to support.  
>
> Once again, in your opinion it is a hack, I don't consider it more a  
> hack than assigning the IP address on the command line.  And I wouldn't  
> call the in kernel stuff useless.
>
You yourself called it a hack in your last note (and I agree).  And, as you're
finding out, the DHCP and NFS code in the kernel is in fact useless if you can't
assign a mac address to your ethernet interface, which in turn you cant do
unless you introduce some unacceptable code to the kernel.

>> Everyone has to invest some time on a tangent to their goal in order to reach
>> their goal.  This is simply a cost of doing business.  No one is going to accept
>> a hack to a driver just so that you don't have to learn how to do something a
>> bit differently.  And no amount of complaining about how difficult it is is
>> going to change that.  Its simply not true.  Theres a big document in the kernel
>> tree explaining how to create and use initramfs/initrd files.  I'll be happy to
>> help you figure out how to do it if you have questions.
>
> I know how to build initrds and initramfs.  I've spent the hard time  
> digging through the code in init/do_mounts.c trying to figure out what  
> it is supposed to do.  I have used them for multiple embedded systems,  
> zoo.weinigel.se/trac/public, both the Acer and the DNS323 use them, but  
> those are hobby projects where I haven't had deadlines to meet.   It is  
> a luxury I usually don't have when my boss drops an embedded system on  
> my desk and tells me "we have to have our drivers working on this board  
> for a demo next week".
>
So, If I read this right:
1) You have undertaken hobby projects for which you have investigated,
implemented and learned how to implement an initramfs, and feel comfortable
doing so.

2) You have a work project for which an initramfs would be helpful and based on
this thread, required  (assuming you don't want to carry extra driver patches on
your own)

3) Your knoweldge from (1) is insufficient to implement the required initramfs in (2)
in (assuming your example time frame) 1 week?

Seriously?

>>> Regarding the flash space, if I have a 1.6MByte kernel image (the 
>>> size  of a  compressed Linux 2.6.24 kernel for a Samsung S3C24A0 
>>> platform I'm  working on), those 400kBytes can make the difference 
>>> between things  fitting into the 2MByte flash partition the 
>>> bootloader has reserved for  the kernel or not.
>>>
>> It can, is that the the actual case?  How much space do you have if you turn off
>> the dhcp client and nfs root code in the kernel? Try hard, I bet you can make it
>> fit without much effort.
>
> Disabling IP_PNP and NFS_ROOT saves less than 8kBytes on an ARM9 (yeah,  
> I just checked).  An initrd uses a lot more than that.  Maybe with  
> klibc, but investing klibc is something that I've had on my TODO list  
> since hpa first talked about it years ago.  I've sort of been putting it  
> off until klibc would get into the kernel, but...
>
Ok, well, thats a start.  Have you considered making some non-essential
functions modular, and storing those functions on your NFS root?  That would
give you the additional space to store an initramfs, which you can use to mout
and pivot to your nfs root, which then gives you access to the additional
modules.  Thats not hard to do at all.

>>> So it mostly boils down to me being lazy and not wanting to spend a 
>>> lot  of time on building new infrastructure.  I'd like something 
>>> which is a  bit better than what we have now and can spend some time 
>>> on it, but I  don't want to spend a lot of time on it since patching 
>>> the driver works  just fine for my purposes.  Perfect is the enemy of 
>>> good.
>>>
>> Well, that is your perogative.  I had to make those sorts of choices when I did
>> embedded too.  I tried to get upstream what was acceptible, and carried the rest
>> myself on occasion. But I promise you, this really isn't hard.  Spend some time,
>> and you'll find and onboard initramfs environment can make your life worlds
>> easier long term.
>
> Yes, and the next time I would have to fix this on an embedded board, I  
> could probably have spent the time on figure out how to do something  
> slightly more generic, but since it won't have a chance of getting into  
> the kernel, I probably won't.
>
> Anyway, I've spent more time on discussing this now than it would have  
> taken me to hack the device drivers on half a dozen platforms, so I  
> think I'll give up.  Maybe I'll take a look at some initrd+klibc+dhcp  
> stuff when I have some free time next Christmas (that's when I usually  
> get to play around with my hobby projects), maybe not. :-)
>
I sympathize with you.  This is exactly what soured me on embedded work a few
years back.  Embedded shops are forever compromising doing things correctly in
the name of time and schedules, never paying any heed to the possibility that
taking extra time to do things in an agreed upon, organized and standard fashion
might pay off for them in the long run.  I encourage you to tell your management
that taking the time to develop this would let you save this time over and over
again in subsequnt probjects.  Track how much time you take keeping up with
that mac address assignment patch as you update kernels.  I had to do that
several times on various projects, and sometimes it helped (although usually it
just made me mad :) )
Neil



   /Christer
>
>
