From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCH 3/8] Sometimes the ISDN chip only controls the D-channel
Date: Thu, 03 May 2012 09:31:04 +0200
Message-ID: <4FA23438.6090103@linux-pingi.de>
References: <1335613404-10187-4-git-send-email-kkeil@linux-pingi.de> <20120501.133007.569588994121475807.davem@davemloft.net> <4FA2265D.6040000@linux-pingi.de> <20120503.025059.1771068683530938115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:56653 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779Ab2ECHg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 03:36:29 -0400
In-Reply-To: <20120503.025059.1771068683530938115.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 03.05.2012 08:50, schrieb David Miller:
> From: Karsten Keil <kkeil@linux-pingi.de>
> Date: Thu, 03 May 2012 08:31:57 +0200
> 
>> I did put the additional PCM infrastructure in this series, because
>> the approval test was done with it in place.
>> I did plan the update of the low level drivers in a separate patchset
>> from the beginning.
>>
>> What do you prefer, adding the driver part now, as additional patch, or
>> removing this additional infrastruckture part and submit it in a later
>> series ?
> 
> I feel like I'm talking to a wall.
> 
> A patch should do one, and only one thing.  It should not have
> changes which are unrelated to that one thing.
> 

Sorry I disagree here, this patch does exactly one thing, it add the
infrastructure in the mISDN core to allow the PCM only B-channel mode.
PCM only mode need a special protocol and a mechanism to set/get/store
the PCM slots of the card, and this is for what the extra stuff is used.


> What part of this is so hard to understand?
> 
> To make matters worse, you didn't even make a mention of those
> unrelated changes in your commit message.
> 

Yes, I was not verbose enough in the commit message and it was my error
to include it in this series, without the use case. Maybe I'm too
deep in the ISDN stuff so I forget that 3 parties do not see how it fit
together.

So would you accept this patch with a changed commit message like this ?

Sometimes the ISDN chip only controls the D-channel

The B-channels are connected only via the PCM backplane.
For this special case we need two things, a protocol which do not enable
the normal IO path and a method to set/get and store the PCM slots to be
used on the backplane.
This patch add the core infrastructure for both. A later patch will
add the methods to the supported low level drivers.

> So that patch was bogus on at least two counts.
> 
> 
