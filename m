From: Willem de Bruijn <willemdebruijn.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v06 18/36] uapi linux/errqueue.h: include linux/time.h in
 user space
Date: Sun, 6 Aug 2017 17:24:20 -0400
Message-ID: <CAF=yD-+w2sboybyUZ-6nKQy1s=Oi1S4Z5yZgksM-CzQjDRG+Vw@mail.gmail.com>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi> <20170806164428.2273-19-mikko.rapeli@iki.fi>
 <CAF=yD-L2ntuH54J_SwN9WcpBMgkV_v0e-Q2Pu2mrQ3+1RozGFQ@mail.gmail.com> <20170806205654.GF28459@lakka.kapsi.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Soheil Hassas Yeganeh <soheil-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170806205654.GF28459-dqH1CgrzRhOk/eJAJmRu5A@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>> > +#ifdef __KERNEL__
>> > +#include <linux/time.h>
>> > +#else
>> > +#include <time.h>
>> > +#endif /* __KERNEL__ */
>>
>> This will break applications that include <linux/time.h> manually.
>> I previously sent a patch to use libc-compat to make compilation succeed
>> when both are included in the case where <linux/time.h> is included after
>> <time.h>.
>>
>>   https://lkml.org/lkml/2016/9/12/872
>>
>> The inverse will require changes to the libc header to avoid redefining
>> symbols already defined by <linux/time.h>
>>
>> The second patch in that 2-patch set included <linux/time.h>
>> unconditionally after the fix. This broke builds that also included
>> <time.h> in the wrong order. I did not resubmit the first patch as a
>> stand-alone, as it is not sufficient to avoid breakage.
>
> I wasn't aware of your change, but I was about to send this to fix the
> case when glibc <time.h> is included before <linux/time.h>:
>
> https://github.com/mcfrisk/linux/commit/f3952a27b8a21c6478d26e6246055383483f6a66

There are a few differences between the two. Including <time.h> does not
unconditionally define all the symbols. Some are conditional on additional
state, such as __timespec_defined.

> but you also ran into problems where <linux/time.h> is included before
> <time.h> which need fixes in libc header side.
>
> So how to proceed with these?

The libc-compat change is a good fix that can be submitted on its own.

> I don't like leaving a few dozen non-compiling header files into uapi.

I agree, but I do not see a simple solution.

Unless libc has the analogous change, including either <time.h> or
<linux/time.h> in userspace can unfortunately cause breakage.

The added include if __KERNEL__ is defined should be safe, though.
