From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v06 18/36] uapi linux/errqueue.h: include linux/time.h in
 user space
Date: Sun, 6 Aug 2017 17:42:13 -0400
Message-ID: <CAF=yD-LN9b9q6sY38eCBM3VyfErQ8sqpQ_7fwkJzMxgjeRFtFg@mail.gmail.com>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi> <20170806164428.2273-19-mikko.rapeli@iki.fi>
 <CAF=yD-L2ntuH54J_SwN9WcpBMgkV_v0e-Q2Pu2mrQ3+1RozGFQ@mail.gmail.com>
 <20170806205654.GF28459@lakka.kapsi.fi> <CAF=yD-+w2sboybyUZ-6nKQy1s=Oi1S4Z5yZgksM-CzQjDRG+Vw@mail.gmail.com>
 <20170806213330.GA31101@lakka.kapsi.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Network Development <netdev@vger.kernel.org>
To: Mikko Rapeli <mikko.rapeli@iki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170806213330.GA31101@lakka.kapsi.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 6, 2017 at 5:33 PM, Mikko Rapeli <mikko.rapeli@iki.fi> wrote:
> On Sun, Aug 06, 2017 at 05:24:20PM -0400, Willem de Bruijn wrote:
>> >> > +#ifdef __KERNEL__
>> >> > +#include <linux/time.h>
>> >> > +#else
>> >> > +#include <time.h>
>> >> > +#endif /* __KERNEL__ */
>> >>
>> >> This will break applications that include <linux/time.h> manually.
>> >> I previously sent a patch to use libc-compat to make compilation succeed
>> >> when both are included in the case where <linux/time.h> is included after
>> >> <time.h>.
>> >>
>> >>   https://lkml.org/lkml/2016/9/12/872
>> >>
>> >> The inverse will require changes to the libc header to avoid redefining
>> >> symbols already defined by <linux/time.h>
>> >>
>> >> The second patch in that 2-patch set included <linux/time.h>
>> >> unconditionally after the fix. This broke builds that also included
>> >> <time.h> in the wrong order. I did not resubmit the first patch as a
>> >> stand-alone, as it is not sufficient to avoid breakage.
>> >
>> > I wasn't aware of your change, but I was about to send this to fix the
>> > case when glibc <time.h> is included before <linux/time.h>:
>> >
>> > https://github.com/mcfrisk/linux/commit/f3952a27b8a21c6478d26e6246055383483f6a66
>>
>> There are a few differences between the two. Including <time.h> does not
>> unconditionally define all the symbols. Some are conditional on additional
>> state, such as __timespec_defined.
>
> Yep, your patch seems better for libc-compat.h. Could you send it again?

Okay. Or feel free to include it in the patchset if that helps resolve
dependencies.

>> > I don't like leaving a few dozen non-compiling header files into uapi.
>>
>> I agree, but I do not see a simple solution.
>>
>> Unless libc has the analogous change, including either <time.h> or
>> <linux/time.h> in userspace can unfortunately cause breakage.
>>
>> The added include if __KERNEL__ is defined should be safe, though.
>
> Yes, for the kernel side, but your libc-compat change would nice for
> userspace, where something will break for sure, but providing source
> API compatibility is sometimes impossible.
>
> To summarize, this change from me, and your libc-compat.c for time.h, or?

I'm still afraid that this patch as is will break builds that include
<linux/time.h> first.
