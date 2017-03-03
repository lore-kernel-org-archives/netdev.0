From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [PATCH 25/26] isdn: eicon: mark divascapi incompatible with kasan
Date: Fri, 3 Mar 2017 18:22:03 +0300
Message-ID: <ecea124d-869d-2d62-ef49-34617391d6a2@virtuozzo.com>
References: <20170302163834.2273519-1-arnd@arndb.de>
 <20170302163834.2273519-26-arnd@arndb.de>
 <6ada42bd-4cc7-4985-3e3b-705cba6e157d@virtuozzo.com>
 <CAK8P3a1AT+x9TiCyC56m6DoiZnxCYcMm6ZtLKXa7nfq=f8kWvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kasan-dev <kasan-dev@googlegroups.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        <linux-media@vger.kernel.org>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        <kernel-build-reports@lists.linaro.org>,
        "David S . Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a1AT+x9TiCyC56m6DoiZnxCYcMm6ZtLKXa7nfq=f8kWvw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03/03/2017 05:54 PM, Arnd Bergmann wrote:
> On Fri, Mar 3, 2017 at 3:20 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>
>>
>> On 03/02/2017 07:38 PM, Arnd Bergmann wrote:
>>> When CONFIG_KASAN is enabled, we have several functions that use rather
>>> large kernel stacks, e.g.
>>>
>>> drivers/isdn/hardware/eicon/message.c: In function 'group_optimization':
>>> drivers/isdn/hardware/eicon/message.c:14841:1: warning: the frame size of 864 bytes is larger than 500 bytes [-Wframe-larger-than=]
>>> drivers/isdn/hardware/eicon/message.c: In function 'add_b1':
>>> drivers/isdn/hardware/eicon/message.c:7925:1: warning: the frame size of 1008 bytes is larger than 500 bytes [-Wframe-larger-than=]
>>> drivers/isdn/hardware/eicon/message.c: In function 'add_b23':
>>> drivers/isdn/hardware/eicon/message.c:8551:1: warning: the frame size of 928 bytes is larger than 500 bytes [-Wframe-larger-than=]
>>> drivers/isdn/hardware/eicon/message.c: In function 'sig_ind':
>>> drivers/isdn/hardware/eicon/message.c:6113:1: warning: the frame size of 2112 bytes is larger than 500 bytes [-Wframe-larger-than=]
>>>
>>> To be on the safe side, and to enable a lower frame size warning limit, let's
>>> just mark this driver as broken when KASAN is in use. I have tried to reduce
>>> the stack size as I did with dozens of other drivers, but failed to come up
>>> with a good solution for this one.
>>>
>>
>> This is kinda radical solution.
>> Wouldn't be better to just increase -Wframe-larger-than for this driver through Makefile?
> 
> I thought about it too, and decided for disabling the driver entirely
> since I suspected that
> not only the per-function stack frame is overly large here but also
> depth of the call chain,
> which would then lead us to hiding an actual stack overflow.
> 

No one complained so far ;)
Disabling the driver like you did will throw it out from allmodconfig so it will receive less compile-testing.


> Note that this driver is almost certainly broken, it hasn't seen any
> updates other than
> style and compile-warning fixes in 10 years and doesn't support any of
> the hardware
> introduced since 2002 (the company still makes PCIe ISDN adapters, but
> the driver
> only supports legacy PCI versions and older buses).

Which means that it's unlikely that someone will run this driver with KASAN and trigger stack overflow (if it's really possible).
