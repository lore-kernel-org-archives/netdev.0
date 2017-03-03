From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 25/26] isdn: eicon: mark divascapi incompatible with kasan
Date: Fri, 3 Mar 2017 15:54:04 +0100
Message-ID: <CAK8P3a1AT+x9TiCyC56m6DoiZnxCYcMm6ZtLKXa7nfq=f8kWvw@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <20170302163834.2273519-26-arnd@arndb.de>
 <6ada42bd-4cc7-4985-3e3b-705cba6e157d@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kasan-dev <kasan-dev@googlegroups.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-media@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <6ada42bd-4cc7-4985-3e3b-705cba6e157d@virtuozzo.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 3:20 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
> On 03/02/2017 07:38 PM, Arnd Bergmann wrote:
>> When CONFIG_KASAN is enabled, we have several functions that use rather
>> large kernel stacks, e.g.
>>
>> drivers/isdn/hardware/eicon/message.c: In function 'group_optimization':
>> drivers/isdn/hardware/eicon/message.c:14841:1: warning: the frame size of 864 bytes is larger than 500 bytes [-Wframe-larger-than=]
>> drivers/isdn/hardware/eicon/message.c: In function 'add_b1':
>> drivers/isdn/hardware/eicon/message.c:7925:1: warning: the frame size of 1008 bytes is larger than 500 bytes [-Wframe-larger-than=]
>> drivers/isdn/hardware/eicon/message.c: In function 'add_b23':
>> drivers/isdn/hardware/eicon/message.c:8551:1: warning: the frame size of 928 bytes is larger than 500 bytes [-Wframe-larger-than=]
>> drivers/isdn/hardware/eicon/message.c: In function 'sig_ind':
>> drivers/isdn/hardware/eicon/message.c:6113:1: warning: the frame size of 2112 bytes is larger than 500 bytes [-Wframe-larger-than=]
>>
>> To be on the safe side, and to enable a lower frame size warning limit, let's
>> just mark this driver as broken when KASAN is in use. I have tried to reduce
>> the stack size as I did with dozens of other drivers, but failed to come up
>> with a good solution for this one.
>>
>
> This is kinda radical solution.
> Wouldn't be better to just increase -Wframe-larger-than for this driver through Makefile?

I thought about it too, and decided for disabling the driver entirely
since I suspected that
not only the per-function stack frame is overly large here but also
depth of the call chain,
which would then lead us to hiding an actual stack overflow.

Note that this driver is almost certainly broken, it hasn't seen any
updates other than
style and compile-warning fixes in 10 years and doesn't support any of
the hardware
introduced since 2002 (the company still makes PCIe ISDN adapters, but
the driver
only supports legacy PCI versions and older buses).

    Arnd
