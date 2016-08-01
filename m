From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH] bpf: fix size of copy_to_user in percpu map.
Date: Mon, 1 Aug 2016 09:30:34 -0700
Message-ID: <CALDO+SbcTh9Gd75wrJRUvo7SG-kCaKDk8fteQKndTz+_NnAccw@mail.gmail.com>
References: <1469752941-7140-1-git-send-email-u9012063@gmail.com>
 <20160729064722.GA54517@ast-mbp.thefacebook.com> <579B0B9F.8040805@iogearbox.net>
 <CALDO+SZueK9ymNjrLAK+00xzR_BTms+qVhy0DAPnJZGrken2rg@mail.gmail.com>
 <579BF2A1.7000709@iogearbox.net> <CALDO+SbhCuc85b=UuSWVc7baScN+MNwwaLKcXeubPL1SJvOT=Q@mail.gmail.com>
 <20160730053415.GA78880@ast-mbp.thefacebook.com> <CALDO+SaVhA4GB+=-LnbZpWyx15wgc8PRFXVD4dO-O5kb+hJE9g@mail.gmail.com>
 <20160801160738.GA99707@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34682 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754238AbcHAQbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 12:31:15 -0400
Received: by mail-io0-f196.google.com with SMTP id g86so14309467ioj.1
        for <netdev@vger.kernel.org>; Mon, 01 Aug 2016 09:31:15 -0700 (PDT)
In-Reply-To: <20160801160738.GA99707@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> And in my /sys/devices/system/cpu, I have cpu0 and cpu1,
>> kernel_max = 63
>> possible = 0-63
>> present = 0-1
>
> glibc is doing
> ls -d /sys/devices/system/cpu/cpu*
> http://osxr.org:8080/glibc/source/sysdeps/unix/sysv/linux/getsysstats.c?v=glibc-2.14#0180
> And /sys/devices/system/cpu/possible shows 0-63 while only two dirs 'cpu0' and 'cpu1'
> are there?!

yes, that's right.
I only have cpu0 and cpu1 directories, while 'possible' shows 0-63.

> If my understanding of cpu_dev_register_generic() in drivers/base/cpu.c
> is correct the number of 'cpu*' dirs should be equal to possible_cpu.
> Could you please debug why is that the case, because then it's probably
> a bug on the kernel side.

Thanks, I will do it.

> I think it's correct for glibc to rely on the number of 'cpu*' dirs.
> Did you boot with possible_cpus=64 command line arg by any chance?
>
No.

>> So sysconf simply reads these entries configured by kernel. Looking at
>> kernel code, "arch/x86/configs/x86_64_defconfig" sets
>> CONFIG_NR_CPUS=64, and later on set_cpu_possible() is called at
>> arch/x86/kernel/smpboot.c, which parses the ACPI multiprocessor table
>> and configured new value. Based on these observations, I think
>> different hypervisor may have different ways of emulating ACPI
>> processor table or BIOS implementation thus these values differ.
>
> What behavior do you see in ESX ?
> btw, rhel7 ships with nr_cpus=5120 and ubuntu default is 256,
> so this lack of acpi in vmware fusion will lead to possible_cpu=5120,
> a lot of pain in per-cpu allocator and linux VMs will not be happy.
> I think vmware has to be fixed first regardless of what we find
> out about 'cpu*' vs /sys/devices/system/cpu/possible
>

Thanks, I will debug it and update when I have more info.
Regards,
William
