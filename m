From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Tue, 23 May 2017 08:28:28 +0530
Message-ID: <CAHgaXd+5h7aMxF83EEkD3iRyeZ1JxAX2oFYJdy3GtcNOWRsBGw@mail.gmail.com>
References: <CAHgaXdKsO2xoKYp7g91g+n+d_1KHSSByLjzBB-WjVXSjhB7qxw@mail.gmail.com>
 <20170510.212952.1440495072777358778.davem@davemloft.net> <CAHgaXdK8LEEUPm4jTRRzCnjwdWAauHmmB=caZsSFY8MmStH89Q@mail.gmail.com>
 <20170510.215218.2185526627014393313.davem@davemloft.net> <CAHgaXdKZ_v+iO7uqEDx7PA7D+xcp1FngGvJ1SRSsGXNQ-iWWDQ@mail.gmail.com>
 <CAHgaXdLJoVUXXGTYs7FYXay5wx=sA-O+=dYhX+r7AQT7vSNfGQ@mail.gmail.com>
 <CAGXu5j+2q4Wwfhuk_DnDaV894A9ZOD=A_AvAU_OZG6KQv0_KMg@mail.gmail.com>
 <CAHgaXdL7GcVzs+ANPke_NywhcgHbe_fzi1sTDEy+Ni1-o82GYQ@mail.gmail.com>
 <591A07A1.1030006@iogearbox.net> <CAHgaXdKKbRVSpX-036TXpV5z=1=QCnPoku0+CeHxHco8-aasPQ@mail.gmail.com>
 <5922E11C.4070307@iogearbox.net> <CAHgaXd+dTEKyPbkB6oFpLa3z0ygkxK1dMT8R55iYjvsU=GO3Wg@mail.gmail.com>
 <CAGXu5jLYunVCJGCfHPebKDaoQ71hdMGq4HhdDxTYpBQw_HXUYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Daniel Borkmann <daniel@iogearbox.net>, David Miller <davem@davemloft.net>,
	Mircea Gherzan <mgherzan@gmail.com>, Network Development <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, ast@fb.com
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-7987-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5jLYunVCJGCfHPebKDaoQ71hdMGq4HhdDxTYpBQw_HXUYQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

Hi,

On testing the eBPF JIT with CONFIG_FRAME_POINTER I got the following
crash for non jitted testcase.

[   72.032494] test_bpf: #267 BPF_MAXINSNS: Call heavy transformations
jited:0 1112799
[   92.304815] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s!
[insmod:104]
[   92.305050] Modules linked in: test_bpf(+)
[   92.305516] CPU: 0 PID: 104 Comm: insmod Not tainted
4.11.0-10603-g13e0988-dirty #21
[   92.305630] Hardware name: ARM-Versatile Express
[   92.305943] task: c75d5280 task.stack: c61b8000
[   92.306383] PC is at __bpf_prog_run+0x818/0x17a8
[   92.306449] LR is at __bpf_prog_run+0xab8/0x17a8
[   92.306510] pc : [<c0407c08>]    lr : [<c0407ea8>]    psr: 20000013
[   92.306510] sp : c61b9a88  ip : c61b9a88  fp : c61b9d4c
[   92.306629] r10: c0404104  r9 : 00000000  r8 : 00000000
[   92.306744] r7 : c0e0b500  r6 : c0c39bb0  r5 : c61b9ad0  r4 : ca314840
[   92.306882] r3 : c0e0b7fc  r2 : 00000000  r1 : c61b9ad8  r0 : 00000000
[   92.307070] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[   92.307285] Control: 10c5387d  Table: 661e0059  DAC: 00000051
[   92.307503] CPU: 0 PID: 104 Comm: insmod Not tainted
4.11.0-10603-g13e0988-dirty #21
[   92.307575] Hardware name: ARM-Versatile Express
[   92.307651] Backtrace:
[   92.307868] [<c030caec>] (dump_backtrace) from [<c030cda8>]
(show_stack+0x18/0x1c)
[   92.308003]  r7:c1503db8 r6:60000193 r5:00000000 r4:c1570f30
[   92.308085] [<c030cd90>] (show_stack) from [<c064b198>]
(dump_stack+0x90/0xa4)
[   92.308195] [<c064b108>] (dump_stack) from [<c030900c>] (show_regs+0x14/0x18)
[   92.308281]  r7:c1503db8 r6:c14488b8 r5:c16aaea0 r4:c61b8000
[   92.308346] [<c0308ff8>] (show_regs) from [<c03df2a4>]
(watchdog_timer_fn+0x24c/0x2c4)
[   92.308423] [<c03df058>] (watchdog_timer_fn) from [<c03b70d8>]
(__hrtimer_run_queues+0x180/0x318)
[   92.308514]  r10:c03df058 r9:00000003 r8:c1503cbc r7:c7ead580
r6:c7ead5c0 r5:c61b8000
[   92.308578]  r4:c7ead8d8
[   92.308635] [<c03b6f58>] (__hrtimer_run_queues) from [<c03b74e8>]
(hrtimer_interrupt+0xb4/0x204)
[   92.308728]  r10:7fffffff r9:00000003 r8:c7ead5f8 r7:c7ead618
r6:c7ead638 r5:c1448580
[   92.308789]  r4:c7ead580
[   92.308835] [<c03b7434>] (hrtimer_interrupt) from [<c03113fc>]
(twd_handler+0x38/0x48)
[   92.308914]  r10:c0404104 r9:00000010 r8:c1504330 r7:00000001
r6:c701e900 r5:00000000
[   92.308974]  r4:00000001
[   92.309021] [<c03113c4>] (twd_handler) from [<c03a1238>]
(handle_percpu_devid_irq+0x90/0x244)
[   92.309091]  r5:00000000 r4:c7020540
[   92.309165] [<c03a11a8>] (handle_percpu_devid_irq) from
[<c039c148>] (generic_handle_irq+0x2c/0x3c)
[   92.309254]  r10:c0404104 r9:c8803100 r8:c7004a00 r7:00000001
r6:00000000 r5:00000000
[   92.309319]  r4:c1449ed0 r3:c03a11a8
[   92.309369] [<c039c11c>] (generic_handle_irq) from [<c039c6f0>]
(__handle_domain_irq+0x64/0xbc)
[   92.309445] [<c039c68c>] (__handle_domain_irq) from [<c0301808>]
(gic_handle_irq+0x5c/0xa0)
[   92.309525]  r9:c8803100 r8:c8802100 r7:c61b9a38 r6:c880210c
r5:c1571848 r4:c1504330
[   92.309596] [<c03017ac>] (gic_handle_irq) from [<c030d98c>]
(__irq_svc+0x6c/0x90)
[   92.309731] Exception stack(0xc61b9a38 to 0xc61b9a80)
[   92.309943] 9a20:
    00000000 c61b9ad8
[   92.310184] 9a40: 00000000 c0e0b7fc ca314840 c61b9ad0 c0c39bb0
c0e0b500 00000000 00000000
[   92.310377] 9a60: c0404104 c61b9d4c c61b9a88 c61b9a88 c0407ea8
c0407c08 20000013 ffffffff
[   92.310595]  r9:c61b8000 r8:00000000 r7:c61b9a6c r6:ffffffff
r5:20000013 r4:c0407c08
[   92.311103] [<c04073f0>] (__bpf_prog_run) from [<bf15759c>]
(test_bpf_init+0x59c/0x1000 [test_bpf])
[   92.311262]  r10:bf123094 r9:ca2fa020 r8:00000000 r7:bf123128
r6:53edefe8 r5:ca2fa000
[   92.311325]  r4:00000555
[   92.311382] [<bf157000>] (test_bpf_init [test_bpf]) from
[<c0301f7c>] (do_one_initcall+0x4c/0x174)
[   92.311468]  r10:bf154640 r9:c61c2524 r8:39e3db1c r7:00000001
r6:00000000 r5:bf157000
[   92.311529]  r4:ffffe000
[   92.311575] [<c0301f30>] (do_one_initcall) from [<c042a5b0>]
(do_init_module+0x6c/0x1fc)
[   92.311673]  r9:c61c2524 r8:39e3db1c r6:c61c2480 r5:00000001 r4:bf154640
[   92.311744] [<c042a544>] (do_init_module) from [<c03d393c>]
(load_module+0x1f8c/0x2394)
[   92.311815]  r6:c61c2500 r5:00000001 r4:c61b9f34
[   92.311898] [<c03d19b0>] (load_module) from [<c03d3ea0>]
(SyS_init_module+0x15c/0x174)
[   92.311979]  r10:00000051 r9:00000000 r8:00160fda r7:c61b8000
r6:c95a6a18 r5:b6fbca20
[   92.312040]  r4:00006a18
[   92.312087] [<c03d3d44>] (SyS_init_module) from [<c0308260>]
(ret_fast_syscall+0x0/0x3c)
[   92.312196]  r10:00000000 r9:c61b8000 r8:c0308424 r7:00000080
r6:756e694c r5:00156a18
[   92.312277]  r4:00000000
[   93.835343] 1065840 PASS

Does this look like a bug? I will send the separate mail if it does.
Let me know.

Best,
Shubham Bansal


On Tue, May 23, 2017 at 1:35 AM, Kees Cook <keescook@chromium.org> wrote:
> On Mon, May 22, 2017 at 10:04 AM, Shubham Bansal
> <illusionist.neo@gmail.com> wrote:
>> These all benchmarks are for ARMv7.
>
> Thanks! In the future, try to avoid the white-space damage
> (line-wrapping). And it looks like you've still got debugging turned
> on in your jit code:
>
> [   56.176033] test_bpf: #21 LD_CPU
> [   56.176329] bpf_jit: *** NOT YET: opcode 85 ***
> [   56.176565] jited:0 2639 702 PASS
>
> That breaks the test report line. After I cleaned these up and parsed
> the results, they look great. Most things are half the speed of the
> interpreter, if not better. Only the LD_ABS suffered, and that's
> mainly the const blinding, I assume.
>
> Please post your current patch. Thanks for this!
>
> -Kees
>
> --
> Kees Cook
> Pixel Security
