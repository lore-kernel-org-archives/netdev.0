From: Dan Williams <dcbw@redhat.com>
Subject: Re: bcm43xx driver unstable behaviour (and linux wireless is junk
	btw)
Date: Sat, 23 Sep 2006 23:50:57 -0400
Message-ID: <1159069857.2748.5.camel@localhost.localdomain>
References: <1159065798.5924.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:17051 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1752085AbWIXDtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2006 23:49:08 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1159065798.5924.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-24 at 12:43 +1000, Benjamin Herrenschmidt wrote:
> Hi folks !
> 
> So this is 2.6.18 + Larry "fix" (though I've seen this problem before,
> it seems using WPA just make it happen more often).
> 
> This is also a 4318, so the link is pretty weak due to the Tx Power
> problem and I suspects it makes the driver problems more visible...
> 
> So basically, I "lose" the link every few minutes for a minute or so, I
> suspect it's related to wpa_supplicant vs. the ack losses due to the
> 4318 Tx Power problems. That alone would be ok though, if the driver
> wasn't totally stuck after a while. (Similar problem to after
> sleep/wakeup, looks like nothign goes through).
> 
> When it goes bunk, it looks like that in the logs:
> 
> Sep 24 12:24:18 localhost kernel: [  285.686826] SoftMAC: Sent Authentication Request to 00:0f:66:52:4b:60.
> Sep 24 12:24:18 localhost kernel: [  285.686976] SoftMAC: generic IE set to <....>
> Sep 24 12:24:18 localhost kernel: [  285.686999] SoftMAC: Already associating or associated to 00:0f:66:52:4b:60
> Sep 24 12:24:28 localhost kernel: [  295.687229] SoftMAC: Start scanning with channel: 1
> Sep 24 12:24:28 localhost kernel: [  295.687240] SoftMAC: Scanning 14 channels
> Sep 24 12:24:29 localhost kernel: [  296.027053] SoftMAC: Scanning finished
> Sep 24 12:24:29 localhost kernel: [  296.035267] SoftMAC: generic IE set to <....>
> Sep 24 12:24:29 localhost kernel: [  296.035310] SoftMAC: Already associating or associated to 00:0f:66:52:4b:60
> Sep 24 12:24:31 localhost kernel: [  297.690969] SoftMAC: Sent Authentication Request to 00:0f:66:52:4b:60.
> Sep 24 12:24:39 localhost kernel: [  306.039210] SoftMAC: Start scanning with channel: 1
> Sep 24 12:24:39 localhost kernel: [  306.039222] SoftMAC: Scanning 14 channels
> Sep 24 12:24:39 localhost kernel: [  306.375046] SoftMAC: Scanning finished
> Sep 24 12:24:39 localhost kernel: [  306.383018] SoftMAC: generic IE set to <....>
> Sep 24 12:24:39 localhost kernel: [  306.383075] SoftMAC: Already associating or associated to 00:0f:66:52:4b:60
> Sep 24 12:24:42 localhost kernel: [  309.695021] SoftMAC: Sent Authentication Request to 00:0f:66:52:4b:60.
> Sep 24 12:24:49 localhost kernel: [  316.387211] SoftMAC: Start scanning with channel: 1
> 
>  etc...
> 
> Then, if you rmmod, you get back a prompt, and about a second later, the kernel blows up. At this point,
> I've always been in X and it's too dead to dump anything into the disk logs so I don't know what
> the precise crash is, but it looks to me like the driver is not properly removing some timer
> or something there.
> 
> Note that it also goes "bunk" on sleep/wakeup, and sometimes ifdown/ifup... in general, it's fragile and
> just 'loses it' in which case the only way to get it back is to rmmod/insmod.
> 
> Doesn't help me to have my prism54 not working with WPA (apparently, the driver looks like it handles hostap
> ioctls but it doesn't agree on the ioctl numbers, among others, with whatever wpa_supplicant sends when
> configured to wpa mode... somebody knows if that driver is maintained ?)

prism54 fullmac, right?

Try using -Dwext; the prism54 wpa_supplicant driver is a dead-end and I
added WE-19 commands to it a bit ago anyway.  Oddly enough, I couldn't
seem to get the driver to work reliably for me using straight WEP
either, let alone WPA.  It's pretty unmaintained at the moment.

Dan

> So at this point I have a choice between two wireless devices that don't work (and none of them is less than
> a couple years old). Looks like the linux wireless situation isn't getting any better since last KS.
> 
> Oh and I don't care about "it works in dscape stack" sort of crap I regulary get. I want something that
> works with upstream kernels. That isn't that much to ask... or is it ?
> 
> Ben, back to ethernet cables.
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

