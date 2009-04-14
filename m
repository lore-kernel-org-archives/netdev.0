From: Gene Heskett <gene.heskett@verizon.net>
Subject: Re: mcp55 forcedeth woes
Date: Tue, 14 Apr 2009 14:27:51 -0400
Message-ID: <200904141427.52112.gene.heskett@verizon.net>
References: <e3e0f4f0ca9fdce35c24b30559d10f31.squirrel@www.datavault.us>
 <49E49F46.8030509@seiner.com> <18916.47906.73896.346385@stoffel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Yan Seiner <yan@seiner.com>, netdev@vger.kernel.org,
	aabdulla@nvidia.com
To: "John Stoffel" <john@stoffel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173003pub.verizon.net ([206.46.173.3]:62126 "EHLO
	vms173003pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758398AbZDNS2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 14:28:04 -0400
Received: from coyote.coyote.den ([141.153.90.107]) by vms173003.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008; 32bit))
 with ESMTPA id <0KI300DNHSMGIBTJ@vms173003.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 14 Apr 2009 13:27:53 -0500 (CDT)
In-reply-to: <18916.47906.73896.346385@stoffel.org>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 14 April 2009, John Stoffel wrote:
I took this offlist before I wear out my aged welcome.
>>>>>> "Yan" == Yan Seiner <yan@seiner.com> writes:
>
>Yan> Gene Heskett wrote:
>>> On Monday 13 April 2009, Yan Seiner wrote:
>>>> Gene Heskett wrote:
>>>>> On Monday 13 April 2009, Yan Seiner wrote:
>>>>>> I have a few Asus M2N-SLI deluxe mobos.  These mobos have the MCP55
>>>>>> chipset and two 1gb ethernet ports.  Occasionally, and for no reason
>>>>>> that I can figure out, these ports will die.  There are various ways
>>>>>> to try and fix these; they seem to be about 50% effective, and
>>>>>> approach something akin to voodoo.
>>>>>>
>>>>>> Based on this discussion here:
>>>>>>
>>>>>> http://patchwork.kernel.org/patch/16212/
>>>>>>
>>>>>> I've gotten the ability to turn the ports on and off somewhat.
>>>>>>
>>>>>> For port 0,
>>>>>>
>>>>>> ethtool -s eth0 autoneg off speed 10 duplex full
>>>>>>
>>>>>> turns on the link, and gets me half-duplex, 10mb/sec. Not much,
>>>>>> granted.
>>>>>>
>>>>>> ethtool -s eth0 autoneg off speed 100 duplex full
>>>>>>
>>>>>> causes the link to go up and down on about a 2 second cycle.
>>>>>>
>>>>>> ethtool -s eth0 autoneg on
>>>>>>
>>>>>> causes the link to drop.
>>>>>>
>>>>>> For port 1, the behavior is similar, except that I can get a stable
>>>>>> 100 mbit connection.
>>>>>>
>>>>>> So the problem is in the autoneg code. It's a driver issue as this is
>>>>>> reported widely to work under windows of various flavors.
>>>>>>
>>>>>> I'm running 2.6.29.1; I'm ok with patching and building kernels, but
>>>>>> I'm not a kernel hacker.
>>>>>>
>>>>>> What, if anything, can I provide and do to fix this?
>>>>>
>>>>> It was in 2.6.29-rc8 or 9 that they finally got the ability to turn
>>>>> them back on on my identical mobo.  Through most of the 29-rcx series
>>>>> we had the choice of rebooting with the reset button, or powering
>>>>> everything associated with the ports down for about 2 minutes so they
>>>>> would forget they were turned off by a graceful shutdown.  Now they are
>>>>> turned off (and I've still NDI why) and back on like they are supposed
>>>>> to be.   I called that a PIMA.
>>>>
>>>> Yeah, I've been fighting this for a while....  The boards are rock-solid
>>>> under load, which is why I like them.... But this is a PITA.
>>>>
>>>> This board worked fine, then I shutdown and the ports have not come back
>>>> since.  I'm running 2.6.29.1 - no joy on the ports.
>>>
>>> Shut it down, including removing the power cord, and unplug all ethernet
>>> cables attached, give it time to fully discharge all stored power in the
>>> caps, at least 30 secs, I usually go make a cup of tea in the microwave,
>>> so its about 3 minutes.  Plug everything back in and power it up, they
>>> should work again.
>>>
>>> However, I've been running 2.6.29.1-rc2, and that has not been a problem,
>>> I can see the leds on the ports go plumb dark at it runs the shutdown,
>>> and come back on about 15 seconds before the init.d/network script runs
>>> as it boots up.
>>>
>>>> I'm building forcedeth from .30-rc1 - we'll see if that helps.
>>>> Something like 15% of the driver changed, so it's still in very heavy
>>>> development.
>>>
>>> Wow!  Like you, I'm using forcedeth. 2.6.29.1-rc1 did have a short uptime
>>> for forcedeth bug IIRC, but so far, -rc2 has lasted longer than KDE-4.2.1
>>> on this F10 system will, I had an 8 day uptime at first, and I'm in the
>>> 5th day again. I killed it the first time screwing with some worthless
>>> bluetooth dongles I got from USBGear.  Locked it up tighter than a
>>> Nebraska bulls ass in flytime. Had to use the reset button. :(
>
>Yan> I followed Gene's advice and got some progress....
>
>Yan> port 0 is now fully functional.  Port 1, however, remains in its
>Yan> semi-zombie state.  Maybe I'll take the machine off-line longer next
>Yan> time.   Maybe I'll sacrifice a black and white chicken at the same
> time.
>
>Yan> I also back-ported 2.9.30-rc1 forcedeth.c to my 2.6.29.1 kernel; no
>Yan> difference whatsoever.
>
>Yan> One other observation:
>
>Yan> On the switch, the status LEDs glow with half-brightness when I enable
>Yan> port 1 using ethtool...  This leads me to suspect that the voltage
>Yan> levels on the port aren't normal.  Not being a hardware engineer, I
> have Yan> no idea what importance this has; I am offering this as an
> observation.
>
>I've also got one of these boards, but I seem to recall that 2.6.28
>and higher worked just fine, but when I was chasing another problem
>with complete system crashes when running tcpdump, I found the dead
>port problem as well.
>
>Thanks for posting your workaround, they'll be a big help.  Esp if I
>put them in early to the system boot process as a quick hack.
>
>The M2N-SLI Deluxe boards are nice though, stable stable stable.  I've
>been very happy with mine.  I wonder if there's a newer BIOS which
>might address some of these issues as well, since it seems to me that
>the BIOS, esp on power up, should be reseting the ports to something
>more sane.
>
>John

I tried to make the last 2 bios updates work here, and I wind up going back to 
1502.zip every time. 1502.zip gives me an instant Oops at boot time, linux 
claims the memory map is bogus and fixes it.  Once fixed, I agree, its 
bulletproof. 

The last 2 bios.zips (1604.zip, 2101.zip) I have do not trigger the Oops, but 
uptimes haven't made it to 24 hours with one of them installed yet. YMMV of 
course.

I haven't checked their site in a month+ though.  There is no place on that 
site to leave bug msgs, and mail sent to admin, webmaster, postmaster, or 
support either bounces or passes too close to a black hole.  I've sent 
several, and frankly, if at the time I was planning on building this machine 
late last summer, I had known about ASUS's non-existant support, I sure as 
hell wouldn't have spent almost 300 USD on the empty motherboard.  That is the 
sort of stuff you expect to get from a $29 motherboard, not a $285 
motherboard.

-- 
Cheers, Gene
"There are four boxes to be used in defense of liberty:
 soap, ballot, jury, and ammo. Please use in that order."
-Ed Howdershelt (Author)
"Let's show this prehistoric bitch how we do things downtown!"
-- The Ghostbusters

