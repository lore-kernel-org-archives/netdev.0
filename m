From: Markos Chandras <Markos.Chandras@imgtec.com>
Subject: Re: [PATCH] Documentation: ptp: Fix build failure on MIPS cross builds
Date: Tue, 21 Oct 2014 14:03:45 +0100
Message-ID: <544659B1.6070509@imgtec.com>
References: <1413794538-28465-1-git-send-email-markos.chandras@imgtec.com> <20141021110724.GA16479@netboy> <54464D6A.5000501@imgtec.com> <20141021125240.GB16479@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-mips@linux-mips.org>, Jonathan Corbet <corbet@lwn.net>,
	<netdev@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Peter Foley <pefoley2@pefoley.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20141021125240.GB16479@netboy>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2014 01:52 PM, Richard Cochran wrote:
> (adding Peter Foley to CC ...)
> 
> On Tue, Oct 21, 2014 at 01:11:22PM +0100, Markos Chandras wrote:
>> On 10/21/2014 12:07 PM, Richard Cochran wrote:
>>> On Mon, Oct 20, 2014 at 09:42:18AM +0100, Markos Chandras wrote:
>>>> diff --git a/Documentation/ptp/Makefile b/Documentation/ptp/Makefile
>>>> index 293d6c09a11f..397c1cd2eda7 100644
>>>> --- a/Documentation/ptp/Makefile
>>>> +++ b/Documentation/ptp/Makefile
>>>> @@ -1,5 +1,15 @@
>>>>  # List of programs to build
>>>> +ifndef CROSS_COMPILE
>>>>  hostprogs-y := testptp
>>>> +else
>>>> +# MIPS system calls are defined based on the -mabi that is passed
>>>> +# to the toolchain which may or may not be a valid option
>>>> +# for the host toolchain. So disable testptp if target architecture
>>>> +# is MIPS but the host isn't.
>>>> +ifndef CONFIG_MIPS
>>>> +hostprogs-y := testptp
>>>> +endif
>>>> +endif
>>>
>>> It seems like a shame to simply give up and not compile this at all.
>>> Is there no way to correctly cross compile this for MIPS?
>>>
>>> Thanks,
>>> Richard
>>>
>>
>> As far as I can see you don't cross-compile the file. You use the host
>> toolchain.
> 
> Look at Documentation/ptp/testptp.mk. There I do use $CROSS_COMPILE.

Hmm I can't see this testptp.mk file in the mainline. What tree are you
referring to?

markos linux (master) $ grep -r CROSS_COMPILE Documentation/ptp/*
markos linux (master) $

-- 
markos
