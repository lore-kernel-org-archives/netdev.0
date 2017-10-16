From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: usb/net/rt2x00: warning in rt2800_eeprom_word_index
Date: Mon, 16 Oct 2017 14:19:33 +0200
Message-ID: <CACT4Y+YB7PTCFCjeqwJeGpSxxAh_U6F6UsDKaN4XAx6uL8+pZw@mail.gmail.com>
References: <CAAeHK+yUNrrNU3Jqrfs7XAT809eyF4nv673cSL8RppbLrDtWNA@mail.gmail.com>
 <20171012072529.GB2686@redhat.com> <CACT4Y+YLM-u7bMfRB=eu_pz1M9iDrY-Qmnho7Hw_Lh3M=LSeMQ@mail.gmail.com>
 <20171016094024.GD2553@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrey Konovalov <andreyknvl@google.com>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016094024.GD2553@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2017 at 11:40 AM, Stanislaw Gruszka <sgruszka@redhat.com> wrote:
> Hi Dmitry
>
> On Sat, Oct 14, 2017 at 04:38:03PM +0200, Dmitry Vyukov wrote:
>> On Thu, Oct 12, 2017 at 9:25 AM, Stanislaw Gruszka <sgruszka@redhat.com> wrote:
>> > Hi
>> >
>> > On Mon, Oct 09, 2017 at 07:50:53PM +0200, Andrey Konovalov wrote:
>> >> I've got the following report while fuzzing the kernel with syzkaller.
>> >>
>> >> On commit 8a5776a5f49812d29fe4b2d0a2d71675c3facf3f (4.14-rc4).
>> >>
>> >> I'm not sure whether this is a bug in the driver, or just a way to
>> >> report misbehaving device. In the latter case this shouldn't be a
>> >> WARN() call, since WARN() means bug in the kernel.
>> >
>> > This is about wrong EEPROM, which reported 3 tx streams on
>> > non 3 antenna device. I think WARN() is justified and thanks
>> > to the call trace I was actually able to to understand what
>> > happened.
>> >
>> > In general I do not think WARN() only means a kernel bug, it
>> > can be F/W or H/W bug too.
>>
>> Hi Stanislaw,
>>
>> Printing messages is fine. Printing stacks is fine. Just please make
>> them distinguishable from kernel bugs and don't kill the whole
>> possibility of automated Linux kernel testing. That's an important
>> capability.
>
> We do not distinguish between bugs and other problems when WARN() is
> used in (wireless) drivers, what I think is correct, taking comment from
> include/asm-generic/bug.h :
>
> /*
>  * WARN(), WARN_ON(), WARN_ON_ONCE, and so on can be used to report
>  * significant issues that need prompt attention if they should ever
>  * appear at runtime.  Use the versions with printk format strings
>  * to provide better diagnostics.
>  */
>
> Historically we have BUG() to mark the bugs, but usage if it is not
> recommended as it can kill the system, so for anything that can
> be recovered in runtime - WARN() is recommended.
>
> Perhaps we can introduce another helper like PROBLEM() for marking
> situations when something is wrong, but it is not a bug. However I'm
> not even sure at what extent it can be used, since for many cases
> if not the most, driver author can not tell apriori if the problem
> is a bug in the driver or HW/FW misbehaviour (or maybe particular
> issue can happen because of both).

I will write a separate email to LKML.

Thanks
