From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 1/3] ptp: Added a brand new class driver for ptp clocks.
Date: Wed, 28 Apr 2010 08:45:37 -0700
Message-ID: <4BD85821.4070904@oracle.com>
References: <20100427091405.GA5098@riccoc20.at.omicron.at> <20100427153239.0977c1aa.randy.dunlap@oracle.com> <20100428060837.GB4516@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:63455 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755197Ab0D1Pp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 11:45:56 -0400
In-Reply-To: <20100428060837.GB4516@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/27/10 23:08, Richard Cochran wrote:
> On Tue, Apr 27, 2010 at 03:32:39PM -0700, Randy Dunlap wrote:
>> How do I use the testptp.mk file?
> 
> The makefile uses the KBUILD_OUTPUT environment variable to find the
> kernel includes, with the new header. I do something like this:
> 
>   export ARCH=powerpc
>   export KBUILD_OUTPUT=~/work/kernel/ptp_p2020
>   mkdir -p $KBUILD_OUTPUT
>   make mpc85xx_smp_defconfig
>   make menuconfig
>   make -j3 uImage
>   make headers_install
>   make -C Documentation/ptp -f testptp.mk
> 
>> Drop the ".ko".  We normally don't include that part of the module name.
> 
> Okay, can do. I just imitated what I saw in other Kbuild files.
> 
>>> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
>>> index 2fc8e14..2d616cb 100644
>>> --- a/include/linux/Kbuild
>>> +++ b/include/linux/Kbuild
>>> @@ -318,6 +318,7 @@ unifdef-y += poll.h
>>>  unifdef-y += ppp_defs.h
>>>  unifdef-y += ppp-comp.h
>>>  unifdef-y += pps.h
>>> +unifdef-y += ptp_clock.h
>>>  unifdef-y += ptrace.h
>>>  unifdef-y += quota.h
>>>  unifdef-y += random.h
>>
>> I think that the Kbuild file also needs this line:
>> header-y += ptp_clock.h
>>
>> so that builds that use O=objdir will work, but even with that
>> change, I couldn't get it to work.  (?)
> 
> Well, I am not sure what to do here. I followed the example of the PPS
> code. That code only has the unifdef-y assigment. But now I see that
> Documentation/kbuild/makefiles.txt says unifdef-y is deprecated.
> 
> Can someone clarify what is correct: is just header-y enough?

Yes, it should be.

-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
