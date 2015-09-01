From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 1/2] net: Remove ndo_xmit_flush netdev operation, use
 signalling instead.
Date: Tue, 1 Sep 2015 12:49:02 -0400
Message-ID: <CAP=VYLo0rNg627UAV4N-vCs6Mq7YCxOFpEFS=DyCxABTbV96UQ@mail.gmail.com>
References: <20140825.163502.973913220915588977.davem@davemloft.net>
 <55E549CE.4010509@windriver.com> <20150901.000051.2053259950492309439.davem@davemloft.net>
 <55E54F5F.9040603@windriver.com> <55E56080.9020502@iogearbox.net> <55E56E0C.7060500@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, therbert@google.com,
	jhs@mojatatu.com, hannes@stressinduktion.org, edumazet@google.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	rusty@rustcorp.com.au, brouer@redhat.com
To: yzhu1 <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:35379 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbbIAQte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:49:34 -0400
Received: by lagj9 with SMTP id j9so1220452lag.2
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:49:32 -0700 (PDT)
In-Reply-To: <55E56E0C.7060500@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 1, 2015 at 5:21 AM, yzhu1 <Yanjun.Zhu@windriver.com> wrote:
> On 09/01/2015 04:23 PM, Daniel Borkmann wrote:
>>

[...]

>>
>> As Dave said, please retest with something up to date, like 4.2 kernel,
>> or latest -net git tree.
>>
>> Besides, the *upstream* xmit_more changes first went into 3.18 ...
>> nearest git describe is at:
>>
>>   $ git describe 0b725a2ca61bedc33a2a63d0451d528b268cf975
>>   v3.17-rc1-251-g0b725a2
>>
>> So, that only tells me, that you are reporting a possible bug based on
>> some non-upstream kernel ... ? Thus, it's not even possible to verify
>> if the actual backport was correct ?
>
>
> Sorry. There is something wrong with backporting this patch.

Please note for the future that this was a completely unacceptable
abuse of the upstream maintainers time by throwing this issue out
there like you did.   These folks all operate assuming everyone
is working on mainline master, and have no way to know what
random commits are in a custom tree -- especially if it isn't even
clear up front that it was a custom tree.   By not mentioning that,
you implicitly are tricking the maintainers into helping you, even
if that was not your actual intent.

If you see a problem, you need to ensure the problem exists on
the latest mainline, and then you can also possibly investigate
the specific commit at where it was added in mainline, to help
better understand the issue.  If you haven't done that, then you
can't be bothering the maintainers like this.  Please ensure this
is well understood by yourself and any others who might also
do the same by accident in the future.

Thanks,
Paul.
--

>
> Thanks for your help.
>
> Zhu Yanjun
>
>
>>
>>> igb 0000:09:00.0: Detected Tx Unit Hang
>>>    Tx Queue <1>
>>>    TDH <1a>
>>>    TDT <1a>
>>>    next_to_use <1d>
>>>    next_to_clean <1a>
>>> buffer_info[next_to_clean]
>>>    time_stamp <ffffeb7d>
>>>    next_to_watch <ffff88103ee711c0>
>>>    jiffies <fffff324>
>>>    desc.status <0>
>>> igb 0000:09:00.0: Detected Tx Unit Hang
>>>    Tx Queue <1>
>>>    TDH <1a>
>>>    TDT <1a>
>>>    next_to_use <1d>
>>>    next_to_clean <1a>
>>> buffer_info[next_to_clean]
>>>    time_stamp <ffffeb7d>
>>>    next_to_watch <ffff88103ee711c0>
>>>    jiffies <fffffaf4>
>>>    desc.status <0>
>>> igb 0000:09:00.0: Detected Tx Unit Hang
>>>    Tx Queue <1>
>>>    TDH <1a>
>>>    TDT <1a>
>>>    next_to_use <1d>
>>>    next_to_clean <1a>
>>> buffer_info[next_to_clean]
>>>    time_stamp <ffffeb7d>
>>>    next_to_watch <ffff88103ee711c0>
>>>    jiffies <1000002c4>
>>>    desc.status <0>
>>> igb 0000:09:00.0: Detected Tx Unit Hang
>>>    Tx Queue <1>
>>>    TDH <1a>
>>>    TDT <1a>
>>>    next_to_use <1d>------------[ cut here ]------------
>>> WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264
>>> dev_watchdog+0x259/0x270()
>>> NETDEV WATCHDOG: eth0 (igb): transmit queue 1 timed out
>>> Modules linked in: x86_pkg_temp_thermal intel_powerclamp coretemp
>>> crct10dif_pclmul crct10dif_common aesni_intel aes_x86_64 glue_helper lrw
>>> gf128mul ablk_helper cryptd iTCO_wdt sb_edac iTCO_vendor_support ipmi_si
>>> edac_core i2c_i801 lpc_ich ipmi_msghandler nfsd fuse
>>> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.14.29ltsi-WR7.0.0.0_standard
>>> #2
>>> Hardware name: Intel Corporation S2600CP/S2600CP, BIOS
>>> RMLSDP.86I.R4.26.D674.1304190022 04/19/2013
>>>   0000000000000009 ffff88081f603da0 ffffffff81ab9bb8 ffff88081f603de8
>>>   ffff88081f603dd8 ffffffff8104c64d 0000000000000001 ffff880812f6d940
>>>   0000000000000000 ffff880813efc000 0000000000000008 ffff88081f603e38
>>> Call Trace:
>>>   <IRQ> [<ffffffff81ab9bb8>] dump_stack+0x4e/0x7a
>>>   [<ffffffff8104c64d>] warn_slowpath_common+0x7d/0xa0
>>>   [<ffffffff8104c6bc>] warn_slowpath_fmt+0x4c/0x50
>>>   [<ffffffff81ac09c7>] ? _raw_spin_unlock+0x17/0x30
>>>   [<ffffffff81998659>] dev_watchdog+0x259/0x270
>>>   [<ffffffff81998400>] ? dev_graft_qdisc+0x80/0x80
>>>   [<ffffffff810594cb>] call_timer_fn+0x3b/0x170
>>>   [<ffffffff81998400>] ? dev_graft_qdisc+0x80/0x80
>>>   [<ffffffff81059d64>] run_timer_softirq+0x1c4/0x2d0
>>>   [<ffffffff81051557>] __do_softirq+0xb7/0x2e0
>>>   [<ffffffff810518be>] irq_exit+0x7e/0xa0
>>>   [<ffffffff81acae74>] smp_apic_timer_interrupt+0x44/0x50
>>>   [<ffffffff81ac9c4a>] apic_timer_interrupt+0x6a/0x70
>>>   <EOI> [<ffffffff81880706>] ? cpuidle_enter_state+0x46/0xb0
>>>   [<ffffffff8188082c>] cpuidle_idle_call+0xbc/0x250
>>>   [<ffffffff8100cdce>] arch_cpu_idle+0xe/0x20
>>>   [<ffffffff810a2bb5>] cpu_startup_entry+0x185/0x290
>>>   [<ffffffff81ab4424>] rest_init+0x84/0x90
>>>   [<ffffffff82333d50>] start_kernel+0x3d6/0x3e3
>>>   [<ffffffff82333495>] x86_64_start_reservations+0x2a/0x2c
>>>   [<ffffffff8233358e>] x86_64_start_kernel+0xf7/0xfa
>>> ---[ end trace 57ad9eaf9dd80dc2 ]---
>>> igb 0000:09:00.0 eth0: Reset adapter
>>> igb: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
>>> igb 0000:09:00.0: Detected Tx Unit Hang
>>>
>>>    next_to_clean <1a>
>>> buffer_info[next_to_clean]
>>>    time_stamp <ffffeb7d>
>>>    next_to_watch <ffff88103ee711c0>
>>>    jiffies <100000a94>
>>>    desc.status <0>
>>>
>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>
>>
>>
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
