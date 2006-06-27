From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 15:06:59 -0500
Message-ID: <44A18FE3.1080403@lwfinger.net>
References: <20060626212547.GE30706@tuxdriver.com> <200606271831.02108.mb@bu3sch.de> <20060627193259.GE1207@tuxdriver.com> <200606272147.04477.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:18563 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932560AbWF0UHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:07:05 -0400
In-Reply-To: <200606272147.04477.mb@bu3sch.de>
To: unlisted-recipients:; (no To-header on input)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Tuesday 27 June 2006 21:33, John W. Linville wrote:
>> On Tue, Jun 27, 2006 at 06:31:01PM +0200, Michael Buesch wrote:
>>> On Tuesday 27 June 2006 18:12, Jeff Garzik wrote:
>>>> Michael Buesch wrote:
>>>>> So, I will submit a patch to lower the udelay(10) to udelay(1)
>>>>> and we can close the discussion? ;)
>>>> No, that totally avoids my point.  Your "otherwise idle machine" test is 
>>>> probably nowhere near worst case in the field, for loops that can 
>>>> potentially lock the CPU for a long time upon hardware fault.  And then 
>>>> there are the huge delays in specific functions that I pointed out...
>>> wtf are you requesting from me?
>>> 1) I proved you that the loop does only spin _once_ or even _less_.
>>> 2) If the hardware is faulty, the user must replace it.
>>>    Because, if the hardware is faulty, it can crash the whole
>>>    machine anyway, obviously.
>>>
>>> 3) There is no "huge delay". I proved it with my logs.
>>>    -> No CPU hog => Nothing to fix.
>> Michael,
>>
>> I think Jeff's concern is that by using udelay you are busy-waiting.
>> And, the for loop limit of 100000 means you could freeze the kernel
>> for up to a whole second.  Granted that this won't happen very often
> 
> s/very often/ever/
> 
> It won't happen, as long as the driver is not buggy, or the device
> is hardware broken. So, if it happens, something has to be fixed.
> In fact, it did happen _never_ for me.
> If it triggers, the device does not work _at all_ anyway.
> 
>> and in the grand scheme of things a second isn't all _that_ long,
>> but still it would be better to avoid a delay like that -- a second
>> could be the time it takes to avoid a meltdown at the nuclear power
>> plant. :-)
>>
>> Could you not use msleep instead of udelay (and scale the for loop
>> appropriately)?  What would be the problem with that?  It would get
>> rid of the busy waiting.
> 
> Becauses it horribly _increases_ the delay.
> We "spin" for _at most_ 10 usecs here. Please always remember that.
> We are talking about a 10 usec delay here. And I already sent a
> patch to even reduce this to under 10 usec.
> 
>> To be fair, this code was already in the driver and was only being
>> moved by this patch.  Still, what better time to fix it than now? :-)
> 
> If it ain't broken, don't fix it.
> 
>> I'll go ahead and reshuffle wireless-2.6 to drop this patch.  A new
>> patch that passes muster w/ Jeff will be most welcome! :-)
> 
> A new patch won't appear, as there is no problem with this
> delay.
> Please don't drop anything and apply the following patch on top
> of it:

John,

I would like to find a diplomatic solution to this impasse between Michael and Jeff, which is why 
I'm writing to you privately. Michael is correct in that the loop in question will not usually delay 
long; however, on some hardware it takes longer than on his. On mine, I have seen delays as long as 
550 usec. In any case, I think that the following code fragment would work and pass Jeff's criticism:

for (i=5000; i; i--) {
	..........
	usleep(1);
}

This would make the worst-case delay be 5 msec, but would provide a cushion of 10X the longest I 
have seen and should be safe.

Do you have any suggestions on what should be done next?

Larry
