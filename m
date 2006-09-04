From: Philip Molter <philip@datafoundry.com>
Subject: Re: tg3: tg3_stop_block timed out
Date: Mon, 04 Sep 2006 16:27:01 -0500
Message-ID: <44FC9A25.9030608@datafoundry.com>
References: <1551EAE59135BE47B544934E30FC4FC093FAF4@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bernd Schubert <bernd-schubert@gmx.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailstar.maildev2.aus.datafoundry.com ([209.99.125.26]:31931
	"EHLO mailstar.maildev2.aus.datafoundry.com") by vger.kernel.org
	with ESMTP id S964987AbWIDV1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 17:27:01 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093FAF4@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> Philip Molter wrote:
> 
>> Is there any additional information that I can give to help get some 
>> more work targeted at this bug?  I've been getting this 
>> lockup three or 
>> four times a week per server (I have four of them exhibiting 
>> this behavior).
>>
>> The network setup is fairly complicated, but unfortunately, these are 
>> production machines pushing multi-gigabit traffic loads.  We're using 
>> vlans on top of bonding on top of anywhere from 2-to-6 
>> broadcomm NICs, 
>> but it appears that the problem is unrelated to the bonding 
>> and vlans, 
>> as others are reporting similar problems without those enabled.
>>
>> Any assistance would be appreciated.  I've left the original 
>> information 
>> below for reference.
> 
> Since you're using a rather old version of tg3, I suggest that you
> upgrade to a newer version first.  Your problem is probably
> different from Bernd Schubert's since he has ASF enabled and you
> don't.
> 
>> If anyone could even explain what this error means, that would be 
>> helpful.  Maybe we can change something to work around it.
>>
> 
> The stop_block error messages are not too important.  The important
> thing is that you're getting a transmit timeout.  It means that
> the tx queue is getting full because the NIC is no longer getting
> interrupts.  When this condition is detected, the NIC will get reset
> which should normally bring the NIC back to life.  It seems that
> in your case, it doesn't come back.  Do you get these timeouts on
> both ports at the same time?

It's hard to tell.  When the error gets logged, it doesn't say which 
interface it's happening on.  The box is locked up by the time we get to 
it, but I think it's happening on both.

I've had NICs lock up with queue issues before, but I've never had it 
lock up a box completely, unresponsive on console even.  Normally, 
network just breaks, and sure, it requires a reboot, but at least we can 
do a controlled reboot.

This only started happening when we moved these NICs to jumbo frames. 
We've used the exact same hardware in less demanding applications (up to 
  500Mbits vs. 750+Mbits) with jumbo without issue, but these particular 
machines, these pushers, only started locking up when we switched to jumbo.

> Please try the latest driver.  If you still get the timeouts, I'll
> need to send you some debug patches to dump the state when these
> timeouts occur.

Will do.
