From: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH v2 1/3] net: smc91x: isolate u16 writes alignment workaround
Date: Mon, 10 Oct 2016 08:30:34 +0200
Message-ID: <87zimc7m2d.fsf@belgarion.home>
References: <1476045227-2970-1-git-send-email-robert.jarzmik@free.fr>
        <CAHp75Vco13D7qQmC8vn6HGg9RYOwR-MgL2uo_cn_OSo4sk84UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Nicolas Pitre <nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org>,
        Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHp75Vco13D7qQmC8vn6HGg9RYOwR-MgL2uo_cn_OSo4sk84UQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
        (Andy Shevchenko's message of "Mon, 10 Oct 2016 00:55:17 +0300")
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

>> +#define SMC_outw(lp, v, a, r)                                          \
>> +       _SMC_outw_align4((v), (a), (r),                                 \
>> +                        IS_BUILTIN(CONFIG_ARCH_PXA) && ((r) & 2) &&    \
>> +                        lp->half_word_align4)
>
> Hmm... Isn't enough to have just (r) & 2 && lp->half_word_align4 ?

It wouldn't be equivalent to what we had before.

The point of the previous code was to compile out as much as possible of this
test. Therefore, at compilation time for omap1 boards, the compiler would
evaluate the test to 0, and never leave the workaround code compiled.

So it would be enough, but worse performance wise and not equivalent for non-pxa
boards, hence this test.

Cheers.

-- 
Robert
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
