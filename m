From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: Fw: [Bug 48701] New: Kernel OOPS when transmitting
 packets using OVS and DSA
Date: Fri, 12 Oct 2012 01:07:36 -0700
Message-ID: <CALnjE+q=t_Ca12A0YxUxeYeY55nx_jx=n3wW8wrqDB921_YrrQ@mail.gmail.com>
References: <20121011093217.44ec3c44@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
To: barry-RiHDFbPRhGT6V6G2DxALlg@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20121011093217.44ec3c44-We1ePj4FEcvRI77zikRAJc56i+j3xesD0e7PPNI6Mm0@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

I could not reproduce it on x86_64 arch and I do not have access to PPC or DSA,
now I am looking at code. meanwhile can you try to reproduce it only with PPC
without DSA, so that we can narrow it down?
one more thing, Are you using any openflow rule for this network or
are there any vlan configured?

Thanks,
Pravin.


On Thu, Oct 11, 2012 at 9:32 AM, Stephen Hemminger
<shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> wrote:
>
>
> Begin forwarded message:
>
> Date: Thu, 11 Oct 2012 16:13:39 +0000 (UTC)
> From: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
> To: shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
> Subject: [Bug 48701] New: Kernel OOPS when transmitting packets using OVS and DSA
>
>
> https://bugzilla.kernel.org/show_bug.cgi?id=48701
>
>            Summary: Kernel OOPS when transmitting packets using OVS and
>                     DSA
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.6.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
>         ReportedBy: barry-RiHDFbPRhGT6V6G2DxALlg@public.gmane.org
>                 CC: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
>         Regression: No
>
>
> When I compiled the kernel (3.6.1 mainline) with distributed switch
> architectural (DSA) and OVS (OpenvSwich), I can pass ping traffic fine, but
> larger packets cause an oops.
>
> This is on a Freescale 83XX Processor:
> # uname -a
> Linux PPCTEST 3.6.1+ #1 PREEMPT Thu Oct 11 08:36:35 PDT 2012 ppc GNU/Linux
> # Unable to handle kernel paging request for data at address 0x12000007
> Faulting instruction address: 0xc008b5ec
> Oops: Kernel access of bad area, sig: 11 [#1]
> PREEMPT SEL B1305
> Modules linked in:
> NIP: c008b5ec LR: c008b5e0 CTR: c0041a68
> REGS: dfffbb30 TRAP: 0300   Not tainted  (3.6.1+)
> MSR: 00001032 <ME,IR,DR,RI>  CR: 22048024  XER: 00000000
> DAR: 12000007, DSISR: 20000000
> TASK = c0407368[0] 'swapper' THREAD: c0424000
> GPR00: c008b5e0 dfffbbe0 c0407368 00100100 00000001 dfb91720 000000c3 c040ae80
> GPR08: 00000000 00000000 c0440d30 c07fd000 24048022 101810a0 c03a79b8 c03abacc
> GPR16: c042e474 00200000 dfffbc1c c034be84 c034be6c dfffbc18 00000000 00008100
> GPR24: 00000000 dfabc000 00000000 df9b8384 00009032 dfb91720 00100100 12000007
> NIP [c008b5ec] kfree+0x64/0xd4
> LR [c008b5e0] kfree+0x58/0xd4
> Call Trace:
> [dfffbbe0] [c008b5e0] kfree+0x58/0xd4 (unreliable)
> [dfffbbf8] [c0217300] skb_free_head+0x4c/0x5c
> [dfffbc00] [c0217bbc] __kfree_skb+0x18/0xbc
> [dfffbc10] [c0314c94] do_execute_actions+0x5f8/0x650
> [dfffbc78] [c0316158] ovs_dp_process_received_packet+0xbc/0xe8
> [dfffbd18] [c0319900] ovs_vport_receive+0x64/0x78
> [dfffbd30] [c031a30c] netdev_frame_hook+0xa0/0xb8
> [dfffbd48] [c021ff68] __netif_receive_skb+0x50c/0x6d0
> [dfffbdb0] [c02f1e1c] dsa_rcv+0x228/0x24c
> [dfffbde0] [c02200b8] __netif_receive_skb+0x65c/0x6d0
> [dfffbe48] [c0221668] napi_skb_finish+0x38/0x88
> [dfffbe58] [c01f5a14] gfar_clean_rx_ring+0x3a4/0x4b0
> [dfffbeb8] [c01f87ac] gfar_poll+0x4c0/0x5dc
> [dfffbf78] [c0225040] net_rx_action+0x74/0x180
> [dfffbfa8] [c001d144] __do_softirq+0xac/0x13c
> [dfffbff0] [c000bd20] call_do_softirq+0x14/0x24
> [c0425e80] [c000500c] do_softirq+0x70/0xb0
> [c0425ea0] [c001d220] irq_exit+0x4c/0x80
> [c0425ea8] [c0005158] do_IRQ+0x10c/0x128
> [c0425ed0] [c000dce0] ret_from_except+0x0/0x14
> --- Exception: 501 at cpu_idle+0x98/0xec
>     LR = cpu_idle+0x98/0xec
> [c0425f90] [c0007f08] cpu_idle+0x54/0xec (unreliable)
> [c0425fa8] [c0003d58] rest_init+0x78/0xa0
> [c0425fc0] [c03dc934] start_kernel+0x288/0x29c
> [c0425ff0] [00003438] 0x3438
> Instruction dump:
> 5529c9f4 7c09582e 7c695a14 70098000 41a20008 8063001c 83c30014 7cbd2b78
> 480fec99 5463103a 7c63f214 83e30058 <813f0000> 801f0004 7f890040 41bc0010
> ---[ end trace ffca2b34cb60156e ]---
>
> Kernel panic - not syncing: Fatal exception in interrupt
> Rebooting in 10 seconds..
>
> This is 100% repeatable.
>
> I had to do some small kernel tweaks to get the DSA drivers to find the
> hardware, so it is possible I broke something, but unlikely since my changes
> were not in this area at all.
>
> Barry
>
> --
> Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are the assignee for the bug.
> _______________________________________________
> dev mailing list
> dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> http://openvswitch.org/mailman/listinfo/dev
