From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] mwifiex: Use put_unaligned_le32
Date: Fri, 06 Oct 2017 16:31:58 +0300
Message-ID: <87vajs4d2p.fsf@codeaurora.org>
References: <1507141686-5178-1-git-send-email-himanshujha199640@gmail.com>
        <874lre5a86.fsf@codeaurora.org>
        <20171005083433.GA11485@himanshu-Vostro-3559>
        <87zi963s1p.fsf@codeaurora.org>
        <20171005152233.GA6250@himanshu-Vostro-3559>
        <20171005180248.GA94139@google.com>
        <20171005190730.GA8043@himanshu-Vostro-3559>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Brian Norris <briannorris@chromium.org>, amitkarwar@gmail.com,
        nishants@marvell.com, gbhat@marvell.com, huxm@marvell.com,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Himanshu Jha <himanshujha199640@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005190730.GA8043@himanshu-Vostro-3559> (Himanshu Jha's
        message of "Fri, 6 Oct 2017 00:37:30 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Himanshu Jha <himanshujha199640@gmail.com> writes:

> On Thu, Oct 05, 2017 at 11:02:50AM -0700, Brian Norris wrote:
>> On Thu, Oct 05, 2017 at 08:52:33PM +0530, Himanshu Jha wrote:
>> > There are various instances where a function used in file say for eg
>> > int func_align (void* a)
>> > is used and it is defined in align.h
>> > But many files don't *directly* include align.h and rather include
>> > any other header which includes align.h
>> 
>> I believe the general rule is that you should included headers for all
>> symbols you use, and not rely on implicit includes.
>> 
>> The modification to the general rule is that not all headers are
>> intended to be included directly, and in such cases there's likely a
>> parent header that is the more appropriate target.
>> 
>> In this case, the key is CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS. It
>> seems that asm-generic/unaligned.h is set up to include different
>> headers, based on the expected architecture behavior.
>>
> Yes, asm-generic/unaligned.h looks more appopriate and is most generic
> implementation of unaligned accesses and  arc specific.
>
> Let's see what Kalle Valo recommends! And then I will send v2 of the
> patch.

Not sure what you are asking from me. But if you are asking should it
be:

#include <asm/unaligned.h>

or:

#include <asm-generic/unaligned.h>

I think it should be the former.

-- 
Kalle Valo
