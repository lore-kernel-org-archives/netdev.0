From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [OOPS][3.12] BUG: unable to handle kernel NULL pointer
 dereference at 0000000c
Date: Fri, 15 Nov 2013 15:29:53 -0700
Message-ID: <CAErSpo4jh7pO=jhZTvHD+sT2O12Ly6V3e_oiac8gHqmdmqevkg@mail.gmail.com>
References: <20131115183422.GA9417@pomac.netswarm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Aring <alex.aring@gmail.com>
To: Ian Kumlien <pomac@vapor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131115183422.GA9417@pomac.netswarm.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[+cc David, Eric, Alex, netdev]

Alex reported a similar issue at
http://marc.info/?l=linux-netdev&m=138355719901790&w=4

On Fri, Nov 15, 2013 at 11:34 AM, Ian Kumlien <pomac@vapor.com> wrote:
> Hi,
>
> After a lot of wondering i finally tracked down the bug that was hitting
> me since 3.12-rc7. Since this is a firewall I haven't actually noticed
> it all the time. But when i saw that it rebooted too often, i enabled
> netconsole and this is the output:
>
> BUG: unable to handle kernel NULL pointer dereference at 0000000c
> IP: [<c18196db>] _decode_session6+0x8b/0x370
> *pde = 00000000
> Oops: 0000 [#1] SMP
> Modules linked in: netconsole tun
> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.12.0 #55
> Hardware name: MICRO-STAR INTERNATIONAL CO., LTD MS-9632/MS-9632, BIOS 6.00 PG 05/16/2007
> task: c1b64880 ti: f600a000 task.ti: c1b5a000
> EIP: 0060:[<c18196db>] EFLAGS: 00210202 CPU: 0
> EIP is at _decode_session6+0x8b/0x370
> EAX: 00000000 EBX: f2c42c00 ECX: 00000001 EDX: e351a0a2
> ESI: 00000000 EDI: f600be70 EBP: f600be34 ESP: f600bdfc
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> CR0: 8005003b CR2: 0000000c CR3: 235e8000 CR4: 000007d0
> Stack:
>  f600be30 00282c00 00000001 c1bb24e0 f63f8000 c1baa780 f2c42c00 c17d653f
>  f2c42c00 c1807178 00000001 00000000 e3791f00 e3791f00 00000000 00000000
>  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> Call Trace:
>  [<c17d653f>] ? __xfrm_decode_session+0x1f/0x30
>  [<c1807178>] ? icmpv6_route_lookup+0xa8/0x170
>  [<c1807693>] ? icmp6_send+0x453/0x6e0
>  [<c177dd7c>] ? ip_local_deliver_finish+0x7c/0x1f0
>  [<c177dd00>] ? ip_rcv_finish+0x310/0x310
>  [<c177db03>] ? ip_rcv_finish+0x113/0x310
>  [<c1807240>] ? icmpv6_route_lookup+0x170/0x170
>  [<c182dc64>] ? icmpv6_send+0x24/0x30
>  [<c180df2f>] ? ip6_expire_frag_queue+0x16f/0x180
>  [<c1823390>] ? nf_ct_net_init+0x60/0x60
>  [<c1075efc>] ? call_timer_fn.isra.27+0x1c/0x80
>  [<c155ff1b>] ? e1000e_poll+0x13b/0x2e0
>  [<c1823390>] ? nf_ct_net_init+0x60/0x60
>  [<c1076094>] ? run_timer_softirq+0x134/0x1d0
>  [<c1071255>] ? __do_softirq+0xa5/0x160
>  [<c10711b0>] ? remote_softirq_cpu_notify+0xa0/0xa0
>  <IRQ>
>  [<c1071416>] ? irq_exit+0x66/0x90
>  [<c105dff5>] ? smp_apic_timer_interrupt+0x35/0x50
>  [<c187196d>] ? apic_timer_interrupt+0x2d/0x34
>  [<c103d8d2>] ? default_idle+0x2/0x10
>  [<c103df26>] ? arch_cpu_idle+0x16/0x20
>  [<c10a1ed9>] ? cpu_startup_entry+0x49/0x130
>  [<c1bc4948>] ? start_kernel+0x29e/0x2a3
>  [<c1bc44ef>] ? repair_env_string+0x4d/0x4d
> Code: 00 00 f3 ab 74 08 66 c7 07 00 00 83 c7 02 83 e6 01 74 03 c6 07 00 8b 83 90 00 00 00 8b 4c 24 08 89 45 08 8b 43 48 83 e0 fe 85 c9 <8b> 40 0c 8b 80 88 00 00 00 89 45 00 0f 84 1b 01 00 00 8b 42 08
> EIP: [<c18196db>] _decode_session6+0x8b/0x370 SS:ESP 0068:f600bdfc
> CR2: 000000000000000c
> ---[ end trace 0cbf7fb6e6aa1f45 ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> ---
>
> Any clue besides just disabling ipv6? ;)
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
