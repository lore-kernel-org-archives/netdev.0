From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: usb/wireless/rsi_91x: use-after-free write in __run_timers
Date: Mon, 25 Sep 2017 15:26:24 +0300
Message-ID: <874lrr6k27.fsf@kamboji.qca.qualcomm.com>
References: <CAAeHK+wXCaLZ8=enfsmjg-+FJsW1UhSCz8GUmSWhFxB4orLQ6w@mail.gmail.com>
        <87lgl3769o.fsf@kamboji.qca.qualcomm.com>
        <CAAeHK+y61FFKLpePKOhRjd=5QJEWRy9-pank64PuG+aKzafANw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Amitkumar Karwar <amit.karwar@redpinesignals.com>,
        Prameela Rani Garnepudi <prameela.j04cs@gmail.com>,
        Karun Eagalapati <karun256@gmail.com>,
        linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+y61FFKLpePKOhRjd=5QJEWRy9-pank64PuG+aKzafANw@mail.gmail.com>
        (Andrey Konovalov's message of "Mon, 25 Sep 2017 13:20:43 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Konovalov <andreyknvl@google.com> writes:

> On Mon, Sep 25, 2017 at 6:26 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
>> Andrey Konovalov <andreyknvl@google.com> writes:
>>
>>> I've got the following report while fuzzing the kernel with syzkaller.
>>>
>>> On commit 6e80ecdddf4ea6f3cd84e83720f3d852e6624a68 (Sep 21).
>>>
>>> ==================================================================
>>> BUG: KASAN: use-after-free in __run_timers+0xc0e/0xd40
>>> Write of size 8 at addr ffff880069f701b8 by task swapper/0/0
>>>
>>> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.14.0-rc1-42311-g6e80ecdddf4e #234
>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>
>> [...]
>>
>>> Allocated by task 1845:
>>>  save_stack_trace+0x1b/0x20 arch/x86/kernel/stacktrace.c:59
>>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>>>  set_track mm/kasan/kasan.c:459
>>>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
>>>  kmem_cache_alloc_trace+0x11e/0x2d0 mm/slub.c:2772
>>>  kmalloc ./include/linux/slab.h:493
>>>  kzalloc ./include/linux/slab.h:666
>>>  rsi_91x_init+0x98/0x510 drivers/net/wireless/rsi/rsi_91x_main.c:203
>>>  rsi_probe+0xb6/0x13b0 drivers/net/wireless/rsi/rsi_91x_usb.c:665
>>>  usb_probe_interface+0x35d/0x8e0 drivers/usb/core/driver.c:361
>>
>> I'm curious about your setup. Apparently you are running syzkaller on
>> QEMU but what I don't understand is how the rsi device comes into the
>> picture. Did you have a rsi usb device connected to the virtual machine
>> or what? Or does syzkaller do some kind of magic here?
>
> I use dummy_hcd and gadgetfs to connect random USB devices to the
> kernel from a userspace application. This happens inside a QEMU
> instance. This simplifies fuzzing, since everything is virtualized,
> but the found bugs can be triggered on a real machine by connecting a
> malicious USB device.

That's very cool, thanks for explaining the setup.

-- 
Kalle Valo
