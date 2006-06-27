From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 15:37:38 -0500
Message-ID: <44A19712.40702@lwfinger.net>
References: <20060626212547.GE30706@tuxdriver.com> <200606272147.04477.mb@bu3sch.de> <44A18FE3.1080403@lwfinger.net> <200606272223.19928.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:28363 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1161282AbWF0Uhp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:37:45 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606272223.19928.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Tuesday 27 June 2006 22:06, Larry Finger wrote:
>> John,
>>
>> I would like to find a diplomatic solution to this impasse between Michael and Jeff, which is why 
>> I'm writing to you privately. Michael is correct in that the loop in question will not usually delay 
> 
> private?

I meant it to be private, but screwed up.

>> long; however, on some hardware it takes longer than on his. On mine, I have seen delays as long as 
>> 550 usec.
> 
> What's the chip?

bcm43xx: Chip ID 0x4306, rev 0x2
bcm43xx: Number of cores: 6
bcm43xx: Core 0: ID 0x800, rev 0x2, vendor 0x4243, enabled
bcm43xx: Core 1: ID 0x812, rev 0x4, vendor 0x4243, disabled
bcm43xx: Core 2: ID 0x80d, rev 0x1, vendor 0x4243, enabled
bcm43xx: Core 3: ID 0x807, rev 0x1, vendor 0x4243, disabled
bcm43xx: Core 4: ID 0x804, rev 0x7, vendor 0x4243, enabled
bcm43xx: Core 5: ID 0x812, rev 0x4, vendor 0x4243, disabled
bcm43xx: Ignoring additional 802.11 core.
bcm43xx: Detected PHY: Version: 1, Type 2, Revision 1
bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)

>> In any case, I think that the following code fragment would work and pass Jeff's criticism: 
>>
>> for (i=5000; i; i--) {
>> 	..........
>> 	usleep(1);
> 
> usleep? Can't find that in my kernel tree.
> In fact, I think the lowest possible sleep time
> depends on HZ and is 1msec on 1000HZ.

I meant udelay, of course.

> Additionally, we are holding a spinlock at this time, so it is
> not as easy as simply replacing udelay() by some sleeping function.

I know that.

>> This would make the worst-case delay be 5 msec, but would provide a cushion of 10X the longest I 
>> have seen and should be safe.
>>
>> Do you have any suggestions on what should be done next?
> 
> Leave it as is and find out why it takes so long for your strange card. ;)

I once offered you my second, duplicate card for testing, but never heard back. Do you have any 
ideas regarding diagnostics to see why it takes so long? Remember, this card used to time-out on the 
1 second delay before the periodic work was restructured.

Larry



