From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Mon, 22 May 2017 12:08:17 -0700
Message-ID: <8c53012b-cb81-5228-de79-f55457d1cf69@gmail.com>
References: <CAHgaXdKsO2xoKYp7g91g+n+d_1KHSSByLjzBB-WjVXSjhB7qxw@mail.gmail.com>
 <20170510.212952.1440495072777358778.davem@davemloft.net>
 <CAHgaXdK8LEEUPm4jTRRzCnjwdWAauHmmB=caZsSFY8MmStH89Q@mail.gmail.com>
 <20170510.215218.2185526627014393313.davem@davemloft.net>
 <CAHgaXdKZ_v+iO7uqEDx7PA7D+xcp1FngGvJ1SRSsGXNQ-iWWDQ@mail.gmail.com>
 <CAHgaXdLJoVUXXGTYs7FYXay5wx=sA-O+=dYhX+r7AQT7vSNfGQ@mail.gmail.com>
 <CAGXu5j+2q4Wwfhuk_DnDaV894A9ZOD=A_AvAU_OZG6KQv0_KMg@mail.gmail.com>
 <CAHgaXdL7GcVzs+ANPke_NywhcgHbe_fzi1sTDEy+Ni1-o82GYQ@mail.gmail.com>
 <591A07A1.1030006@iogearbox.net>
 <CAHgaXdKKbRVSpX-036TXpV5z=1=QCnPoku0+CeHxHco8-aasPQ@mail.gmail.com>
 <CAGXu5j+k+NMQGmmhuW-4pHFd6agfndJfxQ9k--h+ZpsDBVB8ig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Network Development <netdev@vger.kernel.org>, ast@fb.com,
        Mircea Gherzan <mgherzan@gmail.com>,
        David Miller <davem@davemloft.net>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>, nschichan@freebox.fr,
        andrew@lunn.ch
To: Kees Cook <keescook@chromium.org>,
        Shubham Bansal <illusionist.neo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33870 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760788AbdEVTIW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 15:08:22 -0400
Received: by mail-pf0-f196.google.com with SMTP id w69so21862069pfk.1
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 12:08:21 -0700 (PDT)
In-Reply-To: <CAGXu5j+k+NMQGmmhuW-4pHFd6agfndJfxQ9k--h+ZpsDBVB8ig@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2017 11:58 AM, Kees Cook wrote:
> On Sat, May 20, 2017 at 1:01 PM, Shubham Bansal
> <illusionist.neo@gmail.com> wrote:
>> Hi Daniel and Kees,
>>
>> Before I send the patch, I have tested the JIT compiler on ARMv7 but
>> not on ARMv5 or ARMv6. So can you tell me which arch versions I should
>> test it for?
>> Also for my testing, CONFIG_FRAME_POINTER and CONFIG_CPU_BIG_ENDIAN
>> are both disabled. But I need to test JIT with these flags as well.
>> Whenever I put these flags in .config file, the arm kernel is not
>> getting compiler with these flags. Can you tell me why? If you need
>> more information regarding this, please let me know.
> 
> I think it is fine to only target ARMv7. It is harder and harder to
> find devices on v5 or v6 CPUs that would want to be using BPF JIT,
> IMO.

There are still a ton of Marvell-based routers out there (e.g: Kirkwood,
Orion5x) that are ARMv5 and that prompted Nicholas (hey there) to fix
the cBPF JIT a while ago. I don't think you can just ignore those, it's
fine not to target them initially, but arguably, QEMU has decent support
for some ARMv5 platforms that could be used for testing as well
(realview-eb, versatileab/pbm.

These devices are actually perfect candidates for running eBPF and to
some extent XDP because they are slightly under powered compared to
their newest ARMv7/ARMv8 counterparts.

> 
> When they "disappear", it's because there isn't a prerequisite met. I
> either read the Kconfig files or use "make menuconfig" and "search" to
> tell me where a config is defined and what is needed to meet the
> prerequisites.
> 
> In the case of CPU_BIG_ENDIAN, you need ARCH_SUPPORTS_BIG_ENDIAN,
> which appears to be only ARCH_IXP4XX. I don't think you're going to
> find an emulator that will handle this, so I'd suggest ignoring this
> config for now unless you can find someone with that hardware that you
> can work with to test it.
> 
> In the case of CONFIG_FRAME_POINTER, I assume you built a
> THUMB2_KERNEL? I'd read the notes in arch/arm/Kconfig.debug for
> 'config FRAME_POINTER'.

It sounds like we are at the point where Shubham's patches should be
posted so people could test/fix on earlier ARM devices for instance.

Thanks
-- 
Florian
