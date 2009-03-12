From: Christer Weinigel <christer@weinigel.se>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 19:25:10 +0100
Message-ID: <49B95386.2030600@weinigel.se>
References: <49B82566.3070909@weinigel.se> <20090311171354.04c7a63d@nehalam> <49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net> <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312174933.GC24995@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2-1-3-15a.ens.sth.bostream.se ([82.182.31.214]:55799 "EHLO
	zoo.weinigel.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbZCLSZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 14:25:14 -0400
In-Reply-To: <20090312174933.GC24995@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:
> You don't need klibc, you can use regular glibc, and even build statically if
> you like.  You'll have to use dig or host to do name lookups, but thats also
> pretty easy to do.  This really is easier than you think it is :)

Size, size, size.  The killer in the embedded world which rules out 
glibc.  And have you tried to link glibc statically with something that 
uses gethostbyname lately?  It is no longer possible since the 
introduction of all the introduction of the dynamic name lookup crap 
(ok, it's not really crap, I just feel like it's crap every time I try 
to link a networking application statically).  But that's a bit off 
topic since I don't need name lookups just to mount a NFS file system. 
uclibc also seems to have issues with networking and statically linked 
binaries, but I just haven't had time to figure out why yet.

> Well, you've said it there yourself.  What you're proposing is a hack in the
> driver.  This really isn't the place for hacks.  This is the place for doing
> things in as consistent and maintainable a way as possible.  

In my opion, having a "hwaddrs=eth0=00:de:ad:be:ef:01" would be 
consistent and maintainable.  But opinions differ.

> You're last comment is in direct contradiction to what you are saying here.  As
> you've discovered, the in kernel dhcp and nfs root client are useless unless
> your ethernet interface has a mac on it, and if you don't have a mac stored in
> eeprom that the driver can access, you can't assign one without introducing a
> big hack, which no one here is going to support.  

Once again, in your opinion it is a hack, I don't consider it more a 
hack than assigning the IP address on the command line.  And I wouldn't 
call the in kernel stuff useless.

> Everyone has to invest some time on a tangent to their goal in order to reach
> their goal.  This is simply a cost of doing business.  No one is going to accept
> a hack to a driver just so that you don't have to learn how to do something a
> bit differently.  And no amount of complaining about how difficult it is is
> going to change that.  Its simply not true.  Theres a big document in the kernel
> tree explaining how to create and use initramfs/initrd files.  I'll be happy to
> help you figure out how to do it if you have questions.

I know how to build initrds and initramfs.  I've spent the hard time 
digging through the code in init/do_mounts.c trying to figure out what 
it is supposed to do.  I have used them for multiple embedded systems, 
zoo.weinigel.se/trac/public, both the Acer and the DNS323 use them, but 
those are hobby projects where I haven't had deadlines to meet.   It is 
a luxury I usually don't have when my boss drops an embedded system on 
my desk and tells me "we have to have our drivers working on this board 
for a demo next week".

>> Regarding the flash space, if I have a 1.6MByte kernel image (the size  
>> of a  compressed Linux 2.6.24 kernel for a Samsung S3C24A0 platform I'm  
>> working on), those 400kBytes can make the difference between things  
>> fitting into the 2MByte flash partition the bootloader has reserved for  
>> the kernel or not.
>>
> It can, is that the the actual case?  How much space do you have if you turn off
> the dhcp client and nfs root code in the kernel? Try hard, I bet you can make it
> fit without much effort.

Disabling IP_PNP and NFS_ROOT saves less than 8kBytes on an ARM9 (yeah, 
I just checked).  An initrd uses a lot more than that.  Maybe with 
klibc, but investing klibc is something that I've had on my TODO list 
since hpa first talked about it years ago.  I've sort of been putting it 
off until klibc would get into the kernel, but...

>> So it mostly boils down to me being lazy and not wanting to spend a lot  
>> of time on building new infrastructure.  I'd like something which is a  
>> bit better than what we have now and can spend some time on it, but I  
>> don't want to spend a lot of time on it since patching the driver works  
>> just fine for my purposes.  Perfect is the enemy of good.
>>
> Well, that is your perogative.  I had to make those sorts of choices when I did
> embedded too.  I tried to get upstream what was acceptible, and carried the rest
> myself on occasion. But I promise you, this really isn't hard.  Spend some time,
> and you'll find and onboard initramfs environment can make your life worlds
> easier long term.

Yes, and the next time I would have to fix this on an embedded board, I 
could probably have spent the time on figure out how to do something 
slightly more generic, but since it won't have a chance of getting into 
the kernel, I probably won't.

Anyway, I've spent more time on discussing this now than it would have 
taken me to hack the device drivers on half a dozen platforms, so I 
think I'll give up.  Maybe I'll take a look at some initrd+klibc+dhcp 
stuff when I have some free time next Christmas (that's when I usually 
get to play around with my hobby projects), maybe not. :-)

   /Christer

