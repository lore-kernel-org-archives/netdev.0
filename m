From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Tue, 23 May 2017 09:04:40 +0530
Message-ID: <CAHgaXdL2qReJF1Aw08k3C+OiC-3AOy3VeYmQ1Hs7vKcrfGQnvA@mail.gmail.com>
References: <CAHgaXdKsO2xoKYp7g91g+n+d_1KHSSByLjzBB-WjVXSjhB7qxw@mail.gmail.com>
 <20170510.212952.1440495072777358778.davem@davemloft.net> <CAHgaXdK8LEEUPm4jTRRzCnjwdWAauHmmB=caZsSFY8MmStH89Q@mail.gmail.com>
 <20170510.215218.2185526627014393313.davem@davemloft.net> <CAHgaXdKZ_v+iO7uqEDx7PA7D+xcp1FngGvJ1SRSsGXNQ-iWWDQ@mail.gmail.com>
 <CAHgaXdLJoVUXXGTYs7FYXay5wx=sA-O+=dYhX+r7AQT7vSNfGQ@mail.gmail.com>
 <CAGXu5j+2q4Wwfhuk_DnDaV894A9ZOD=A_AvAU_OZG6KQv0_KMg@mail.gmail.com>
 <CAHgaXdL7GcVzs+ANPke_NywhcgHbe_fzi1sTDEy+Ni1-o82GYQ@mail.gmail.com>
 <591A07A1.1030006@iogearbox.net> <CAHgaXdKKbRVSpX-036TXpV5z=1=QCnPoku0+CeHxHco8-aasPQ@mail.gmail.com>
 <CAGXu5j+k+NMQGmmhuW-4pHFd6agfndJfxQ9k--h+ZpsDBVB8ig@mail.gmail.com> <8c53012b-cb81-5228-de79-f55457d1cf69@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kees Cook <keescook@chromium.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Network Development <netdev@vger.kernel.org>, ast@fb.com,
        Mircea Gherzan <mgherzan@gmail.com>,
        David Miller <davem@davemloft.net>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>, nschichan@freebox.fr,
        andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:36727 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752255AbdEWDem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 23:34:42 -0400
Received: by mail-oi0-f54.google.com with SMTP id h4so185672439oib.3
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 20:34:42 -0700 (PDT)
In-Reply-To: <8c53012b-cb81-5228-de79-f55457d1cf69@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

>> I think it is fine to only target ARMv7. It is harder and harder to
>> find devices on v5 or v6 CPUs that would want to be using BPF JIT,
>> IMO.
>
> There are still a ton of Marvell-based routers out there (e.g: Kirkwood,
> Orion5x) that are ARMv5 and that prompted Nicholas (hey there) to fix
> the cBPF JIT a while ago. I don't think you can just ignore those, it's
> fine not to target them initially, but arguably, QEMU has decent support
> for some ARMv5 platforms that could be used for testing as well
> (realview-eb, versatileab/pbm.

I am using busybox to get the rootfs. Here is what I am doing :-

1. ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j4 (for kernel
build as well as busybox build)
2. qemu-system-arm -M vexpress-a9 -dtb
./linux/arch/arm/boot/dts/versatile-ab.dts -kernel ./linux/arch/a
rm/boot/zImage -append "root=/dev/mmcblk0 console=ttyAMA0" -sd
./a9rootfs.ext3 --nographic

Can you help me with running qemu for ARMv5 and ARMv6 ?

>> When they "disappear", it's because there isn't a prerequisite met. I
>> either read the Kconfig files or use "make menuconfig" and "search" to
>> tell me where a config is defined and what is needed to meet the
>> prerequisites.
>>
>> In the case of CPU_BIG_ENDIAN, you need ARCH_SUPPORTS_BIG_ENDIAN,
>> which appears to be only ARCH_IXP4XX. I don't think you're going to
>> find an emulator that will handle this, so I'd suggest ignoring this
>> config for now unless you can find someone with that hardware that you
>> can work with to test it.
>>
>> In the case of CONFIG_FRAME_POINTER, I assume you built a
>> THUMB2_KERNEL? I'd read the notes in arch/arm/Kconfig.debug for
>> 'config FRAME_POINTER'.
>
> It sounds like we are at the point where Shubham's patches should be
> posted so people could test/fix on earlier ARM devices for instance.
>
I would post them as soon as I test them on ARMv5 and ARMv6. If you
can help me with that, please let me know.

> Thanks
> --
> Florian

-Shubham
