From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 25/26] isdn: eicon: mark divascapi incompatible with kasan
Date: Fri, 3 Mar 2017 16:37:20 +0100
Message-ID: <CAK8P3a3aMQ+q8o2rFEJ+qLQvauJsOi4kYRp41123qa5+hjY8sA@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <20170302163834.2273519-26-arnd@arndb.de>
 <6ada42bd-4cc7-4985-3e3b-705cba6e157d@virtuozzo.com> <CAK8P3a1AT+x9TiCyC56m6DoiZnxCYcMm6ZtLKXa7nfq=f8kWvw@mail.gmail.com>
 <ecea124d-869d-2d62-ef49-34617391d6a2@virtuozzo.com>
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
In-Reply-To: <ecea124d-869d-2d62-ef49-34617391d6a2@virtuozzo.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 4:22 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> On 03/03/2017 05:54 PM, Arnd Bergmann wrote:
>> On Fri, Mar 3, 2017 at 3:20 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>> On 03/02/2017 07:38 PM, Arnd Bergmann wrote:
>>>
>>> This is kinda radical solution.
>>> Wouldn't be better to just increase -Wframe-larger-than for this driver through Makefile?
>>
>> I thought about it too, and decided for disabling the driver entirely
>> since I suspected that
>> not only the per-function stack frame is overly large here but also
>> depth of the call chain,
>> which would then lead us to hiding an actual stack overflow.
>>
>
> No one complained so far ;)
> Disabling the driver like you did will throw it out from allmodconfig so it will receive less compile-testing.

Good point, I'll add a driver specific flag then and leave it there.

>> Note that this driver is almost certainly broken, it hasn't seen any
>> updates other than
>> style and compile-warning fixes in 10 years and doesn't support any of
>> the hardware
>> introduced since 2002 (the company still makes PCIe ISDN adapters, but
>> the driver
>> only supports legacy PCI versions and older buses).
>
> Which means that it's unlikely that someone will run this driver with KASAN
and trigger stack overflow (if it's really possible).

True.

   Arnd
