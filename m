From: Peter Williams <peterw@aurema.com>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Thu, 13 May 2004 09:33:48 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40A2B45C.7070206@aurema.com>
References: <20040512020700.6f6aa61f.akpm@osdl.org>	<20040512181903.GG13421@kroah.com>	<40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu>	<200405121947.i4CJlJm5029666@turing-police.cc.vt.edu> <Pine.LNX.4.58.0405121255170.11950@bigblue.dev.mdolabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, Andrew Morton <akpm@osdl.org>,
        Netdev <netdev@oss.sgi.com>, Greg KH <greg@kroah.com>,
        Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jgarzik@pobox.com>,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Davide Libenzi <davidel@xmailserver.org>
In-Reply-To: <Pine.LNX.4.58.0405121255170.11950@bigblue.dev.mdolabs.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Davide Libenzi wrote:
> On Wed, 12 May 2004 Valdis.Kletnieks@vt.edu wrote:
> 
> 
>>On Wed, 12 May 2004 21:33:49 +0200, Ingo Molnar said:
>>
>>>* Jeff Garzik <jgarzik@pobox.com> wrote:
>>>
>>>
>>>>>Woah, that's new.  And wrong.  The code in include/asm-i386/param.h that
>>>>>says:
>>>>>	# define JIFFIES_TO_MSEC(x)     (x)
>>>>>	# define MSEC_TO_JIFFIES(x)     (x)
>>>>>
>>>>>Is not correct.  Look at kernel/sched.c for verification of this :)
>>>>
>>>>
>>>>Yes, that is _massively_ broken.
>>>
>>>why is it wrong?
>>
>>If the kernel jiffie is anything other than exactly 1 msec, you're screwed... 
> 
> 
> I believe they were talking about include/asm-i386/param.h
>                                           ^^^^^^^^

There's sometimes a need to change HZ on i386 systems.  Specifically, 
some IDE drives are unable to safely use DMA (this is documented in one 
of the Kconfig files).  Without DMA for the IDE drives many systems 
experience (a lot of) missed interrupts which can lead to (among other 
things) lost ticks and very erratic and unpredictable behaviour from 
input devices such as the mouse.

Also, if defined in terms of HZ only one definition of these macros 
would be required rather than one for each architecture.

Peter
-- 
Dr Peter Williams, Chief Scientist                peterw@aurema.com
Aurema Pty Limited                                Tel:+61 2 9698 2322
PO Box 305, Strawberry Hills NSW 2012, Australia  Fax:+61 2 9699 9174
79 Myrtle Street, Chippendale NSW 2008, Australia http://www.aurema.com
