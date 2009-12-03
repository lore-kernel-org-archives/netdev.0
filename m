From: kapil dakhane <kdakhane@gmail.com>
Subject: Re: [PATCH] tcp: Fix a connect() race with timewait sockets
Date: Wed, 2 Dec 2009 18:43:31 -0800
Message-ID: <99d458640912021843y21ad07a4j724003328da07e9@mail.gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>
	 <4B152F97.1090409@gmail.com>
	 <20091202.005937.177088443.davem@davemloft.net>
	 <4B163226.50801@gmail.com> <4B164293.7070804@gmail.com>
	 <20091202113213.GA18453@ioremap.net>
	 <99d458640912021118y42a6fe4bm7b742a2046ad7a3b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <99d458640912021118y42a6fe4bm7b742a2046ad7a3b@mail.gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric,

I ran the test again after patching my kernel with your changes.
Unfortunately, the result appear to be the same.
Here's what I get from /var/log/messages:

Dec  2 14:42:17 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
---same message repeats every minute---
Dec  2 14:55:25 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 14:56:31 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 14:57:37 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 14:58:42 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 14:59:48 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 15:00:54 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 15:01:59 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 15:03:05 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:04:11 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:05:16 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:06:22 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c24>]
[<ffffffff81285c24>] inet_csk_bind_conflict+0x1e/0xa6
Dec  2 15:07:28 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 15:08:33 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c45>]
[<ffffffff81285c45>] inet_csk_bind_conflict+0x3f/0xa6
Dec  2 15:09:39 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:10:45 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:11:50 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:12:56 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:14:02 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c65>]
[<ffffffff81285c65>] inet_csk_bind_conflict+0x5f/0xa6
Dec  2 15:15:07 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 15:16:13 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:17:19 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:18:25 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:19:30 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 15:20:36 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 15:21:42 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 15:22:47 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:23:53 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:24:59 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:26:04 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 15:27:10 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
---same message repeats every minute---
Dec  2 15:43:35 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:44:41 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 15:45:47 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:46:52 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:47:58 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:49:04 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:50:09 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 15:51:15 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:52:21 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c9f>]
[<ffffffff81285c9f>] inet_csk_bind_conflict+0x99/0xa6
Dec  2 15:53:26 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 15:54:32 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6

Here's detailed stack from first minute:

Dec  2 14:42:17 cap-x6270-01 kernel: BUG: soft lockup - CPU#14 stuck
for 61s! [fast:14591]
Dec  2 14:42:17 cap-x6270-01 kernel: Modules linked in: xt_TPROXY
xt_MARK xt_socket nf_defrag_ipv4 nf_tproxy_core iptable_mangle ipv6
autofs4 hidp rfcomm l2cap bluetooth rfkill sunrpc 8021q xt_state
nf_conntrack xt_tcpudp iptable_filter ip_tables x_tables
cpufreq_ondemand acpi_cpufreq freq_table dm_multipath scsi_dh video
output sbs sbshc battery acpi_memhotplug ac parport_pc lp parport
joydev sg serio_raw rtc_cmos button rtc_core rtc_lib igb niu i2c_i801
i2c_core pcspkr dm_snapshot dm_zero dm_mirror dm_region_hash dm_log
dm_mod usb_storage ahci libata shpchp aacraid sd_mod scsi_mod ext3 jbd
uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
Dec  2 14:42:17 cap-x6270-01 kernel: CPU 14:
Dec  2 14:42:17 cap-x6270-01 kernel: Modules linked in: ....
Dec  2 14:42:17 cap-x6270-01 kernel: Pid: 14591, comm: fast Tainted: G
       W  2.6.31.4 #3 SUN BLADE X6270 SERVER MODULE
Dec  2 14:42:17 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 14:42:17 cap-x6270-01 kernel: RSP: 0018:ffff8804e1471e30
EFLAGS: 00000282
Dec  2 14:42:17 cap-x6270-01 kernel: RAX: ffffffff815c4101 RBX:
ffff8804ea477da0 RCX: ffff8808c54a5820
Dec  2 14:42:17 cap-x6270-01 kernel: RDX: ffff8809041922c0 RSI:
0000000000000000 RDI: ffff8809071340c0
Dec  2 14:42:17 cap-x6270-01 kernel: RBP: ffffffff8100c42e R08:
00000000a900220e R09: ffff8804de0bc0a0
Dec  2 14:42:17 cap-x6270-01 kernel: R10: 00007fff281a1501 R11:
ffff8809071340c0 R12: ffffffff812509d4
Dec  2 14:42:17 cap-x6270-01 kernel: R13: ffff88097b9a38c0 R14:
0000000000000246 R15: 0000000000000001
Dec  2 14:42:17 cap-x6270-01 kernel: FS:  00007f2c0e2006e0(0000)
GS:ffffc90001c00000(0000) knlGS:0000000000000000
Dec  2 14:42:17 cap-x6270-01 kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
0000000080050033
Dec  2 14:42:17 cap-x6270-01 kernel: CR2: 0000000020fe7000 CR3:
000000097b1b1000 CR4: 00000000000006e0
Dec  2 14:42:17 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Dec  2 14:42:17 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Dec  2 14:42:17 cap-x6270-01 kernel: Call Trace:
Dec  2 14:42:17 cap-x6270-01 kernel:  [<ffffffff81285a30>] ?
inet_csk_get_port+0x1b2/0x29e
Dec  2 14:42:17 cap-x6270-01 kernel:  [<ffffffff812a15e2>] ?
inet_bind+0x10c/0x1b7
Dec  2 14:42:17 cap-x6270-01 kernel:  [<ffffffff8124ef53>] ? sys_bind+0x6e/0x9e
Dec  2 14:42:17 cap-x6270-01 kernel:  [<ffffffff8106de14>] ?
audit_syscall_entry+0x1a4/0x1cf
Dec  2 14:42:17 cap-x6270-01 kernel:  [<ffffffff8100b92b>] ?
system_call_fastpath+0x16/0x1b

Dec  2 14:42:26 cap-x6270-01 kernel: BUG: soft lockup - CPU#4 stuck
for 61s! [swapper:0]
Dec  2 14:42:26 cap-x6270-01 kernel: Modules linked in: ...
Dec  2 14:42:26 cap-x6270-01 kernel: CPU 4:
Dec  2 14:42:26 cap-x6270-01 kernel: Modules linked in: ...
Dec  2 14:42:26 cap-x6270-01 kernel: Pid: 0, comm: swapper Tainted: G
      W  2.6.31.4 #3 SUN BLADE X6270 SERVER MODULE
Dec  2 14:42:26 cap-x6270-01 kernel: RIP: 0010:[<ffffffff812dee49>]
[<ffffffff812dee49>] _spin_lock+0xa/0x15
Dec  2 14:42:26 cap-x6270-01 kernel: RSP: 0018:ffffc90000803c98
EFLAGS: 00000297
Dec  2 14:42:26 cap-x6270-01 kernel: RAX: 000000000000e5e4 RBX:
ffff8808d94f1bc0 RCX: ffff8808d94f1bc0
Dec  2 14:42:26 cap-x6270-01 kernel: RDX: ffffffff81b4b340 RSI:
ffff8808c8570e80 RDI: ffffc90019f82a20
Dec  2 14:42:26 cap-x6270-01 kernel: RBP: ffffffff8100c433 R08:
8000000000000000 R09: 0400000000000000
Dec  2 14:42:26 cap-x6270-01 kernel: R10: 0000000000000000 R11:
0000000000000000 R12: ffffc90000803c10
Dec  2 14:42:26 cap-x6270-01 kernel: R13: ffffc90019f82a20 R14:
ffffc90000803c10 R15: ffffffff8101da86
Dec  2 14:42:26 cap-x6270-01 kernel: FS:  0000000000000000(0000)
GS:ffffc90000800000(0000) knlGS:0000000000000000
Dec  2 14:42:26 cap-x6270-01 kernel: CS:  0010 DS: 0018 ES: 0018 CR0:
000000008005003b
Dec  2 14:42:26 cap-x6270-01 kernel: CR2: 00007f436db8f000 CR3:
0000000001001000 CR4: 00000000000006e0
Dec  2 14:42:26 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Dec  2 14:42:26 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Dec  2 14:42:26 cap-x6270-01 kernel: Call Trace:
Dec  2 14:42:26 cap-x6270-01 kernel:  <IRQ>  [<ffffffff81284d1d>] ?
__inet_twsk_hashdance+0x54/0x127
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff812979d0>] ?
tcp_time_wait+0x13c/0x1c0
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8128bbc5>] ? tcp_fin+0x7e/0x178
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8128c782>] ?
tcp_data_queue+0x2b4/0xaf9
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8128fce1>] ?
tcp_rcv_state_process+0x8a7/0x909
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff812951cc>] ?
tcp_v4_do_rcv+0x181/0x1d5
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff81296be2>] ?
tcp_v4_rcv+0x4ac/0x706
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8127c950>] ?
ip_rcv_finish+0x0/0x366
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8127cdd6>] ?
ip_local_deliver_finish+0x120/0x1e3
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8127cc9c>] ?
ip_rcv_finish+0x34c/0x366
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8127d20e>] ? ip_rcv+0x289/0x2d0
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8125e156>] ?
process_backlog+0x6f/0x98
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8125df97>] ?
net_rx_action+0xa9/0x17d
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff810444ca>] ?
__do_softirq+0xc5/0x183
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8100ca5c>] ?
call_softirq+0x1c/0x28
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8100ddf2>] ?
do_softirq+0x2c/0x68
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8100d472>] ? do_IRQ+0xa0/0xb6
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8100c2d3>] ?
ret_from_intr+0x0/0xa
Dec  2 14:42:26 cap-x6270-01 kernel:  <EOI>  [<ffffffff8100c42e>] ?
apic_timer_interrupt+0xe/0x20
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff811b3292>] ?
acpi_idle_enter_simple+0x120/0x14e
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff811b3288>] ?
acpi_idle_enter_simple+0x116/0x14e
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8123bbb4>] ?
cpuidle_idle_call+0x7f/0xbb
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8100aa1d>] ? cpu_idle+0x40/0x5e

Dec  2 14:42:26 cap-x6270-01 kernel: BUG: soft lockup - CPU#12 stuck
for 61s! [swapper:0]
...
Dec  2 14:42:26 cap-x6270-01 kernel: Pid: 0, comm: swapper Tainted: G
      W  2.6.31.4 #3 SUN BLADE X6270 SERVER MODULE
Dec  2 14:42:26 cap-x6270-01 kernel: RIP: 0010:[<ffffffff812dee4f>]
[<ffffffff812dee4f>] _spin_lock+0x10/0x15
Dec  2 14:42:26 cap-x6270-01 kernel: RSP: 0018:ffffc90001803ec8
EFLAGS: 00000297
Dec  2 14:42:26 cap-x6270-01 kernel: RAX: 0000000000004a49 RBX:
ffff8808c8570e80 RCX: ffff8808c8571168
Dec  2 14:42:26 cap-x6270-01 kernel: RDX: ffffc90001803f00 RSI:
0000000000000100 RDI: ffff8808c8570ec8
Dec  2 14:42:26 cap-x6270-01 kernel: RBP: ffffffff8100c433 R08:
0000000000000010 R09: 0000000000000000
Dec  2 14:42:26 cap-x6270-01 kernel: R10: 0000000000000000 R11:
0000000000000000 R12: ffffc90001803e40
Dec  2 14:42:26 cap-x6270-01 kernel: R13: ffff88097cdf0000 R14:
0000000000000082 R15: ffffffff8101da86
Dec  2 14:42:26 cap-x6270-01 kernel: FS:  0000000000000000(0000)
GS:ffffc90001800000(0000) knlGS:0000000000000000
Dec  2 14:42:26 cap-x6270-01 kernel: CS:  0010 DS: 0018 ES: 0018 CR0:
000000008005003b
Dec  2 14:42:26 cap-x6270-01 kernel: CR2: 0000000021601ff8 CR3:
0000000001001000 CR4: 00000000000006e0
Dec  2 14:42:26 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Dec  2 14:42:26 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Dec  2 14:42:26 cap-x6270-01 kernel: Call Trace:
Dec  2 14:42:26 cap-x6270-01 kernel:  <IRQ>  [<ffffffff81293b71>] ?
tcp_write_timer+0x16/0x5c9
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff81293b5b>] ?
tcp_write_timer+0x0/0x5c9
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff81048575>] ?
run_timer_softirq+0x131/0x197
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff810444ca>] ?
__do_softirq+0xc5/0x183
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8100ca5c>] ?
call_softirq+0x1c/0x28
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8100ddf2>] ?
do_softirq+0x2c/0x68
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8101da8b>] ?
smp_apic_timer_interrupt+0x88/0x95
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8100c433>] ?
apic_timer_interrupt+0x13/0x20
Dec  2 14:42:26 cap-x6270-01 kernel:  <EOI>  [<ffffffff8100c42e>] ?
apic_timer_interrupt+0xe/0x20
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff811b3147>] ?
acpi_idle_enter_bm+0x249/0x274
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff811b313d>] ?
acpi_idle_enter_bm+0x23f/0x274
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8123bbb4>] ?
cpuidle_idle_call+0x7f/0xbb
Dec  2 14:42:26 cap-x6270-01 kernel:  [<ffffffff8100aa1d>] ? cpu_idle+0x40/0x5e

Dec  2 14:42:28 cap-x6270-01 kernel: BUG: soft lockup - CPU#11 stuck
for 61s! [swapper:0]
...
Dec  2 14:42:28 cap-x6270-01 kernel: Pid: 0, comm: swapper Tainted: G
      W  2.6.31.4 #3 SUN BLADE X6270 SERVER MODULE
Dec  2 14:42:28 cap-x6270-01 kernel: RIP: 0010:[<ffffffff812dee4f>]
[<ffffffff812dee4f>] _spin_lock+0x10/0x15
Dec  2 14:42:28 cap-x6270-01 kernel: RSP: 0018:ffffc90001603eb8
EFLAGS: 00000297
Dec  2 14:42:28 cap-x6270-01 kernel: RAX: 0000000000004746 RBX:
ffff8804a798ad00 RCX: ffff8804a798afe8
Dec  2 14:42:28 cap-x6270-01 kernel: RDX: ffffc90001603ef0 RSI:
ffff8804f2858a40 RDI: ffff8804a798ad48
Dec  2 14:42:28 cap-x6270-01 kernel: RBP: ffffffff8100c433 R08:
ffff88097cdea000 R09: 0000000000000003
Dec  2 14:42:28 cap-x6270-01 kernel: R10: ffffffff811a52f0 R11:
0000000000000000 R12: ffffc90001603e30
Dec  2 14:42:28 cap-x6270-01 kernel: R13: ffff8804fcdd4000 R14:
ffffc90001603e30 R15: ffffffff8101da86
Dec  2 14:42:28 cap-x6270-01 kernel: FS:  0000000000000000(0000)
GS:ffffc90001600000(0000) knlGS:0000000000000000
Dec  2 14:42:28 cap-x6270-01 kernel: CS:  0010 DS: 0018 ES: 0018 CR0:
000000008005003b
Dec  2 14:42:28 cap-x6270-01 kernel: CR2: 0000000007225000 CR3:
00000004e318d000 CR4: 00000000000006e0
Dec  2 14:42:28 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Dec  2 14:42:28 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Dec  2 14:42:28 cap-x6270-01 kernel: Call Trace:
Dec  2 14:42:28 cap-x6270-01 kernel:  <IRQ>  [<ffffffff81293b71>] ?
tcp_write_timer+0x16/0x5c9
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff81293b5b>] ?
tcp_write_timer+0x0/0x5c9
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff81048575>] ?
run_timer_softirq+0x131/0x197
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff810444ca>] ?
__do_softirq+0xc5/0x183
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8100ca5c>] ?
call_softirq+0x1c/0x28
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8100ddf2>] ?
do_softirq+0x2c/0x68
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8100d472>] ? do_IRQ+0xa0/0xb6
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8100c2d3>] ?
ret_from_intr+0x0/0xa
Dec  2 14:42:28 cap-x6270-01 kernel:  <EOI>  [<ffffffff811a52f0>] ?
acpi_hw_register_read+0x52/0xe5
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff811b3292>] ?
acpi_idle_enter_simple+0x120/0x14e
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff811b3288>] ?
acpi_idle_enter_simple+0x116/0x14e
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff811b2fd3>] ?
acpi_idle_enter_bm+0xd5/0x274
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8123bbb4>] ?
cpuidle_idle_call+0x7f/0xbb
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8100aa1d>] ? cpu_idle+0x40/0x5e

Dec  2 14:42:28 cap-x6270-01 kernel: BUG: soft lockup - CPU#15 stuck
for 61s! [swapper:0]
...
Dec  2 14:42:28 cap-x6270-01 kernel: Pid: 0, comm: swapper Tainted: G
      W  2.6.31.4 #3 SUN BLADE X6270 SERVER MODULE
Dec  2 14:42:28 cap-x6270-01 kernel: RIP: 0010:[<ffffffff812dee51>]
[<ffffffff812dee51>] _spin_lock+0x12/0x15
Dec  2 14:42:28 cap-x6270-01 kernel: RSP: 0018:ffffc90001e03ce8
EFLAGS: 00000293
Dec  2 14:42:28 cap-x6270-01 kernel: RAX: 000000000000e6e4 RBX:
ffff8808df9e9b40 RCX: ffff8808df9e9b40
Dec  2 14:42:28 cap-x6270-01 kernel: RDX: ffffffff81b4b340 RSI:
ffff8804a798ad00 RDI: ffffc90019f82a20
Dec  2 14:42:28 cap-x6270-01 kernel: RBP: ffffffff8100c433 R08:
000000001a8082c7 R09: 0000000003069b61
Dec  2 14:42:28 cap-x6270-01 kernel: R10: 0000001400c21ca1 R11:
ffff8804681763c0 R12: ffffc90001e03c60
Dec  2 14:42:28 cap-x6270-01 kernel: R13: ffffc90019f82a20 R14:
ffffc90001e03c60 R15: ffffffff8101da86
Dec  2 14:42:28 cap-x6270-01 kernel: FS:  0000000000000000(0000)
GS:ffffc90001e00000(0000) knlGS:0000000000000000
Dec  2 14:42:28 cap-x6270-01 kernel: CS:  0010 DS: 0018 ES: 0018 CR0:
000000008005003b
Dec  2 14:42:28 cap-x6270-01 kernel: CR2: 0000000007438398 CR3:
00000004f45a5000 CR4: 00000000000006e0
Dec  2 14:42:28 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Dec  2 14:42:28 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Dec  2 14:42:28 cap-x6270-01 kernel: Call Trace:
Dec  2 14:42:28 cap-x6270-01 kernel:  <IRQ>  [<ffffffff81284d1d>] ?
__inet_twsk_hashdance+0x54/0x127
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff812979d0>] ?
tcp_time_wait+0x13c/0x1c0
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8128fc1a>] ?
tcp_rcv_state_process+0x7e0/0x909
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff812951cc>] ?
tcp_v4_do_rcv+0x181/0x1d5
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff81296be2>] ?
tcp_v4_rcv+0x4ac/0x706
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8127c950>] ?
ip_rcv_finish+0x0/0x366
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8127cdd6>] ?
ip_local_deliver_finish+0x120/0x1e3
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8127cc9c>] ?
ip_rcv_finish+0x34c/0x366
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8127d20e>] ? ip_rcv+0x289/0x2d0
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8125e156>] ?
process_backlog+0x6f/0x98
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8125df97>] ?
net_rx_action+0xa9/0x17d
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff810444ca>] ?
__do_softirq+0xc5/0x183
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8100ca5c>] ?
call_softirq+0x1c/0x28
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8100ddf2>] ?
do_softirq+0x2c/0x68
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8100d472>] ? do_IRQ+0xa0/0xb6
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8100c2d3>] ?
ret_from_intr+0x0/0xa
Dec  2 14:42:28 cap-x6270-01 kernel:  <EOI>  [<ffffffff811a52f0>] ?
acpi_hw_register_read+0x52/0xe5
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff812def52>] ?
_spin_unlock_irqrestore+0x4/0x5
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff811b32ab>] ?
acpi_idle_enter_simple+0x139/0x14e
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff811b2fd3>] ?
acpi_idle_enter_bm+0xd5/0x274
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8123bbb4>] ?
cpuidle_idle_call+0x7f/0xbb
Dec  2 14:42:28 cap-x6270-01 kernel:  [<ffffffff8100aa1d>] ? cpu_idle+0x40/0x5e

Dec  2 14:42:31 cap-x6270-01 kernel: BUG: soft lockup - CPU#13 stuck
for 61s! [fast:14590]
...
Dec  2 14:42:31 cap-x6270-01 kernel: Pid: 14590, comm: fast Tainted: G
       W  2.6.31.4 #3 SUN BLADE X6270 SERVER MODULE
Dec  2 14:42:31 cap-x6270-01 kernel: RIP: 0010:[<ffffffff812dee4f>]
[<ffffffff812dee4f>] _spin_lock+0x10/0x15
Dec  2 14:42:31 cap-x6270-01 kernel: RSP: 0018:ffff8804dd95be30
EFLAGS: 00000293
Dec  2 14:42:31 cap-x6270-01 kernel: RAX: 000000000000e7e4 RBX:
00000000ffffffea RCX: 0000000000000000
Dec  2 14:42:31 cap-x6270-01 kernel: RDX: 00000000000000a2 RSI:
0000000000000fa2 RDI: ffffc90019f82a20
Dec  2 14:42:31 cap-x6270-01 kernel: RBP: ffffffff8100c42e R08:
ffff8809311a6840 R09: 000000004b16ed16
Dec  2 14:42:31 cap-x6270-01 kernel: R10: 00007ffff6230734 R11:
ffff8809311a6840 R12: ffffffff812509d4
Dec  2 14:42:31 cap-x6270-01 kernel: R13: ffff88097404b2c0 R14:
0000000000000246 R15: 0000000000000000
Dec  2 14:42:31 cap-x6270-01 kernel: FS:  00007f0b9511d6e0(0000)
GS:ffffc90001a00000(0000) knlGS:0000000000000000
Dec  2 14:42:31 cap-x6270-01 kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
0000000080050033
Dec  2 14:42:31 cap-x6270-01 kernel: CR2: 00007f11263c7000 CR3:
00000004de426000 CR4: 00000000000006e0
Dec  2 14:42:31 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Dec  2 14:42:31 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Dec  2 14:42:31 cap-x6270-01 kernel: Call Trace:
Dec  2 14:42:31 cap-x6270-01 kernel:  [<ffffffff812859d5>] ?
inet_csk_get_port+0x157/0x29e
Dec  2 14:42:31 cap-x6270-01 kernel:  [<ffffffff812a15e2>] ?
inet_bind+0x10c/0x1b7
Dec  2 14:42:31 cap-x6270-01 kernel:  [<ffffffff8124ef53>] ? sys_bind+0x6e/0x9e
Dec  2 14:42:31 cap-x6270-01 kernel:  [<ffffffff8106de14>] ?
audit_syscall_entry+0x1a4/0x1cf
Dec  2 14:42:31 cap-x6270-01 kernel:  [<ffffffff8100b92b>] ?
system_call_fastpath+0x16/0x1b
...
Dec  2 14:42:45 cap-x6270-01 kernel: BUG: soft lockup - CPU#5 stuck
for 61s! [swapper:0]
...
Dec  2 14:42:45 cap-x6270-01 kernel: Pid: 0, comm: swapper Tainted: G
      W  2.6.31.4 #3 SUN BLADE X6270 SERVER MODULE
Dec  2 14:42:45 cap-x6270-01 kernel: RIP: 0010:[<ffffffff812dee4f>]
[<ffffffff812dee4f>] _spin_lock+0x10/0x15
Dec  2 14:42:45 cap-x6270-01 kernel: RSP: 0018:ffffc90000a03ce8
EFLAGS: 00000297
Dec  2 14:42:45 cap-x6270-01 kernel: RAX: 000000000000e8e4 RBX:
ffff8808be888200 RCX: ffff8808be888200
Dec  2 14:42:45 cap-x6270-01 kernel: RDX: ffffffff81b4b340 RSI:
ffff88092090ec40 RDI: ffffc90019f82a20
Dec  2 14:42:45 cap-x6270-01 kernel: RBP: ffffffff8100c433 R08:
000000006d4b0f59 R09: 00000000a15a9061
Dec  2 14:42:45 cap-x6270-01 kernel: R10: 0000001400c25cd8 R11:
ffff880460516d80 R12: ffffc90000a03c60
Dec  2 14:42:45 cap-x6270-01 kernel: R13: ffffc90019f82a20 R14:
ffffc90000a03c60 R15: ffffffff8101da86
Dec  2 14:42:45 cap-x6270-01 kernel: FS:  0000000000000000(0000)
GS:ffffc90000a00000(0000) knlGS:0000000000000000
Dec  2 14:42:45 cap-x6270-01 kernel: CS:  0010 DS: 0018 ES: 0018 CR0:
000000008005003b
Dec  2 14:42:45 cap-x6270-01 kernel: CR2: 00007f436db8f000 CR3:
0000000001001000 CR4: 00000000000006e0
Dec  2 14:42:45 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Dec  2 14:42:45 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Dec  2 14:42:45 cap-x6270-01 kernel: Call Trace:
Dec  2 14:42:45 cap-x6270-01 kernel:  <IRQ>  [<ffffffff81284d1d>] ?
__inet_twsk_hashdance+0x54/0x127
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff812979d0>] ?
tcp_time_wait+0x13c/0x1c0
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8128fc1a>] ?
tcp_rcv_state_process+0x7e0/0x909
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff812951cc>] ?
tcp_v4_do_rcv+0x181/0x1d5
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff81296be2>] ?
tcp_v4_rcv+0x4ac/0x706
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8127c950>] ?
ip_rcv_finish+0x0/0x366
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8127cdd6>] ?
ip_local_deliver_finish+0x120/0x1e3
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8127cc9c>] ?
ip_rcv_finish+0x34c/0x366
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8127d20e>] ? ip_rcv+0x289/0x2d0
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8125e156>] ?
process_backlog+0x6f/0x98
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8125df97>] ?
net_rx_action+0xa9/0x17d
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff810444ca>] ?
__do_softirq+0xc5/0x183
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8100ca5c>] ?
call_softirq+0x1c/0x28
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8100ddf2>] ?
do_softirq+0x2c/0x68
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8100d472>] ? do_IRQ+0xa0/0xb6
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8100c2d3>] ?
ret_from_intr+0x0/0xa
Dec  2 14:42:45 cap-x6270-01 kernel:  <EOI>  [<ffffffff8100c2ce>] ?
common_interrupt+0xe/0x13
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff811b3147>] ?
acpi_idle_enter_bm+0x249/0x274
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff811b313d>] ?
acpi_idle_enter_bm+0x23f/0x274
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8123bbb4>] ?
cpuidle_idle_call+0x7f/0xbb
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8100aa1d>] ? cpu_idle+0x40/0x5e
...
Dec  2 14:42:45 cap-x6270-01 kernel: BUG: soft lockup - CPU#7 stuck
for 61s! [swapper:0]
...
Dec  2 14:42:45 cap-x6270-01 kernel: Pid: 0, comm: swapper Tainted: G
      W  2.6.31.4 #3 SUN BLADE X6270 SERVER MODULE
Dec  2 14:42:45 cap-x6270-01 kernel: RIP: 0010:[<ffffffff812dee4f>]
[<ffffffff812dee4f>] _spin_lock+0x10/0x15
Dec  2 14:42:45 cap-x6270-01 kernel: RSP: 0018:ffffc90000e03ec8
EFLAGS: 00000297
Dec  2 14:42:45 cap-x6270-01 kernel: RAX: 0000000000005251 RBX:
ffff88092090ec40 RCX: ffff88092090ef28
Dec  2 14:42:45 cap-x6270-01 kernel: RDX: ffffc90000e03f00 RSI:
000000001a35d954 RDI: ffff88092090ec88
Dec  2 14:42:45 cap-x6270-01 kernel: RBP: ffffffff8100c433 R08:
0000000000000010 R09: 0000000000000000
Dec  2 14:42:45 cap-x6270-01 kernel: R10: ffffffff811a52f0 R11:
0000000000000000 R12: ffffc90000e03e40
Dec  2 14:42:45 cap-x6270-01 kernel: R13: ffff88097cd9c000 R14:
ffffc90000e03e40 R15: ffffffff8101da86
Dec  2 14:42:45 cap-x6270-01 kernel: FS:  0000000000000000(0000)
GS:ffffc90000e00000(0000) knlGS:0000000000000000
Dec  2 14:42:45 cap-x6270-01 kernel: CS:  0010 DS: 0018 ES: 0018 CR0:
000000008005003b
Dec  2 14:42:45 cap-x6270-01 kernel: CR2: 000000000c0b25f8 CR3:
0000000973c37000 CR4: 00000000000006e0
Dec  2 14:42:45 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Dec  2 14:42:45 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Dec  2 14:42:45 cap-x6270-01 kernel: Call Trace:
Dec  2 14:42:45 cap-x6270-01 kernel:  <IRQ>  [<ffffffff81054c63>] ?
hrtimer_run_queues+0xed/0x193
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff81293b71>] ?
tcp_write_timer+0x16/0x5c9
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff81293b5b>] ?
tcp_write_timer+0x0/0x5c9
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff81048575>] ?
run_timer_softirq+0x131/0x197
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff810444ca>] ?
__do_softirq+0xc5/0x183
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8100ca5c>] ?
call_softirq+0x1c/0x28
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8100ddf2>] ?
do_softirq+0x2c/0x68
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8101da8b>] ?
smp_apic_timer_interrupt+0x88/0x95
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8100c433>] ?
apic_timer_interrupt+0x13/0x20
Dec  2 14:42:45 cap-x6270-01 kernel:  <EOI>  [<ffffffff811a52f0>] ?
acpi_hw_register_read+0x52/0xe5
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff811b3292>] ?
acpi_idle_enter_simple+0x120/0x14e
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff811b3288>] ?
acpi_idle_enter_simple+0x116/0x14e
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff811b2fd3>] ?
acpi_idle_enter_bm+0xd5/0x274
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8123bbb4>] ?
cpuidle_idle_call+0x7f/0xbb
Dec  2 14:42:45 cap-x6270-01 kernel:  [<ffffffff8100aa1d>] ? cpu_idle+0x40/0x5e
...
Dec  2 14:43:01 cap-x6270-01 kernel: BUG: soft lockup - CPU#1 stuck
for 61s! [swapper:0]
...
Dec  2 14:43:01 cap-x6270-01 kernel: Pid: 0, comm: swapper Tainted: G
      W  2.6.31.4 #3 SUN BLADE X6270 SERVER MODULE
Dec  2 14:43:01 cap-x6270-01 kernel: RIP: 0010:[<ffffffff812dee4f>]
[<ffffffff812dee4f>] _spin_lock+0x10/0x15
Dec  2 14:43:01 cap-x6270-01 kernel: RSP: 0018:ffffc90000203c98
EFLAGS: 00000293
Dec  2 14:43:01 cap-x6270-01 kernel: RAX: 000000000000e9e4 RBX:
ffff88045ad1a3c0 RCX: ffff88045ad1a3c0
Dec  2 14:43:01 cap-x6270-01 kernel: RDX: ffffffff81b4b340 RSI:
ffff880496117800 RDI: ffffc90019f82a20
Dec  2 14:43:01 cap-x6270-01 kernel: RBP: ffffffff8100c433 R08:
8000000000000000 R09: 0400000000000000
Dec  2 14:43:01 cap-x6270-01 kernel: R10: 0000000000000000 R11:
0000000000000000 R12: ffffc90000203c10
Dec  2 14:43:01 cap-x6270-01 kernel: R13: ffffc90019f82a20 R14:
ffffc90000203c10 R15: ffffffff8101da86
Dec  2 14:43:01 cap-x6270-01 kernel: FS:  0000000000000000(0000)
GS:ffffc90000200000(0000) knlGS:0000000000000000
Dec  2 14:43:01 cap-x6270-01 kernel: CS:  0010 DS: 0018 ES: 0018 CR0:
000000008005003b
Dec  2 14:43:01 cap-x6270-01 kernel: CR2: 00007f3ff426a000 CR3:
0000000001001000 CR4: 00000000000006e0
Dec  2 14:43:01 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Dec  2 14:43:01 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Dec  2 14:43:01 cap-x6270-01 kernel: Call Trace:
Dec  2 14:43:01 cap-x6270-01 kernel:  <IRQ>  [<ffffffff81284d1d>] ?
__inet_twsk_hashdance+0x54/0x127
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff812979d0>] ?
tcp_time_wait+0x13c/0x1c0
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8128bbc5>] ? tcp_fin+0x7e/0x178
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8128c782>] ?
tcp_data_queue+0x2b4/0xaf9
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8128fce1>] ?
tcp_rcv_state_process+0x8a7/0x909
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff812951cc>] ?
tcp_v4_do_rcv+0x181/0x1d5
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff81296be2>] ?
tcp_v4_rcv+0x4ac/0x706
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8127c950>] ?
ip_rcv_finish+0x0/0x366
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8127cdd6>] ?
ip_local_deliver_finish+0x120/0x1e3
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8127cc9c>] ?
ip_rcv_finish+0x34c/0x366
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8127d20e>] ? ip_rcv+0x289/0x2d0
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8125e156>] ?
process_backlog+0x6f/0x98
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8125df97>] ?
net_rx_action+0xa9/0x17d
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff810444ca>] ?
__do_softirq+0xc5/0x183
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8100ca5c>] ?
call_softirq+0x1c/0x28
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8100ddf2>] ?
do_softirq+0x2c/0x68
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8100d472>] ? do_IRQ+0xa0/0xb6
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8100c2d3>] ?
ret_from_intr+0x0/0xa
Dec  2 14:43:01 cap-x6270-01 kernel:  <EOI>  [<ffffffff8100c2ce>] ?
common_interrupt+0xe/0x13
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff811b3147>] ?
acpi_idle_enter_bm+0x249/0x274
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff811b313d>] ?
acpi_idle_enter_bm+0x23f/0x274
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8123bbb4>] ?
cpuidle_idle_call+0x7f/0xbb
Dec  2 14:43:01 cap-x6270-01 kernel:  [<ffffffff8100aa1d>] ? cpu_idle+0x40/0x5e
...
Dec  2 14:43:04 cap-x6270-01 kernel: BUG: soft lockup - CPU#9 stuck
for 61s! [swapper:0]
...
Dec  2 14:43:04 cap-x6270-01 kernel: Pid: 0, comm: swapper Tainted: G
      W  2.6.31.4 #3 SUN BLADE X6270 SERVER MODULE
Dec  2 14:43:04 cap-x6270-01 kernel: RIP: 0010:[<ffffffff812dee4f>]
[<ffffffff812dee4f>] _spin_lock+0x10/0x15
Dec  2 14:43:04 cap-x6270-01 kernel: RSP: 0018:ffffc90001203ec8
EFLAGS: 00000297
Dec  2 14:43:04 cap-x6270-01 kernel: RAX: 0000000000008382 RBX:
ffff880496117800 RCX: ffff880496117ae8
Dec  2 14:43:04 cap-x6270-01 kernel: RDX: ffff88048a8fe4e8 RSI:
0000000039b18490 RDI: ffff880496117848
Dec  2 14:43:04 cap-x6270-01 kernel: RBP: ffffffff8100c433 R08:
0000000000000010 R09: 0000000000000000
Dec  2 14:43:04 cap-x6270-01 kernel: R10: 0000000000000009 R11:
0000000000000000 R12: ffffc90001203e40
Dec  2 14:43:04 cap-x6270-01 kernel: R13: ffff8804fcd9c000 R14:
ffffc90001203e40 R15: ffffffff8101da86
Dec  2 14:43:04 cap-x6270-01 kernel: FS:  0000000000000000(0000)
GS:ffffc90001200000(0000) knlGS:0000000000000000
Dec  2 14:43:04 cap-x6270-01 kernel: CS:  0010 DS: 0018 ES: 0018 CR0:
000000008005003b
Dec  2 14:43:04 cap-x6270-01 kernel: CR2: 0000000003dd0000 CR3:
0000000001001000 CR4: 00000000000006e0
Dec  2 14:43:04 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Dec  2 14:43:04 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Dec  2 14:43:04 cap-x6270-01 kernel: Call Trace:
Dec  2 14:43:04 cap-x6270-01 kernel:  <IRQ>  [<ffffffff81054c63>] ?
hrtimer_run_queues+0xed/0x193
Dec  2 14:43:04 cap-x6270-01 kernel:  [<ffffffff81293b71>] ?
tcp_write_timer+0x16/0x5c9
Dec  2 14:43:04 cap-x6270-01 kernel:  [<ffffffff81293b5b>] ?
tcp_write_timer+0x0/0x5c9
Dec  2 14:43:04 cap-x6270-01 kernel:  [<ffffffff81048575>] ?
run_timer_softirq+0x131/0x197
Dec  2 14:43:04 cap-x6270-01 kernel:  [<ffffffff810444ca>] ?
__do_softirq+0xc5/0x183
Dec  2 14:43:04 cap-x6270-01 kernel:  [<ffffffff8100ca5c>] ?
call_softirq+0x1c/0x28
Dec  2 14:43:04 cap-x6270-01 kernel:  [<ffffffff8100ddf2>] ?
do_softirq+0x2c/0x68
Dec  2 14:43:04 cap-x6270-01 kernel:  [<ffffffff8101da8b>] ?
smp_apic_timer_interrupt+0x88/0x95
Dec  2 14:43:04 cap-x6270-01 kernel:  [<ffffffff8100c433>] ?
apic_timer_interrupt+0x13/0x20
Dec  2 14:43:04 cap-x6270-01 kernel:  <EOI>  [<ffffffff8100c42e>] ?
apic_timer_interrupt+0xe/0x20
Dec  2 14:43:04 cap-x6270-01 kernel:  [<ffffffff811b3147>] ?
acpi_idle_enter_bm+0x249/0x274
Dec  2 14:43:04 cap-x6270-01 kernel:  [<ffffffff811b313d>] ?
acpi_idle_enter_bm+0x23f/0x274
Dec  2 14:43:04 cap-x6270-01 kernel:  [<ffffffff8123bbb4>] ?
cpuidle_idle_call+0x7f/0xbb
Dec  2 14:43:04 cap-x6270-01 kernel:  [<ffffffff8100aa1d>] ? cpu_idle+0x40/0x5e
...
Dec  2 14:43:23 cap-x6270-01 kernel: BUG: soft lockup - CPU#14 stuck
for 61s! [fast:14591]
...
Dec  2 14:43:23 cap-x6270-01 kernel: Pid: 14591, comm: fast Tainted: G
       W  2.6.31.4 #3 SUN BLADE X6270 SERVER MODULE
Dec  2 14:43:23 cap-x6270-01 kernel: RIP: 0010:[<ffffffff81285c94>]
[<ffffffff81285c94>] inet_csk_bind_conflict+0x8e/0xa6
Dec  2 14:43:23 cap-x6270-01 kernel: RSP: 0018:ffff8804e1471e30
EFLAGS: 00000286
Dec  2 14:43:23 cap-x6270-01 kernel: RAX: ffffffff815c4101 RBX:
ffff8804ea477da0 RCX: ffff8804e1028ea0
Dec  2 14:43:23 cap-x6270-01 kernel: RDX: ffff88048a4842c0 RSI:
0000000000000000 RDI: ffff8809071340c0
Dec  2 14:43:23 cap-x6270-01 kernel: RBP: ffffffff8100c42e R08:
00000000a900220e R09: ffff8804d2cbcca0
Dec  2 14:43:23 cap-x6270-01 kernel: R10: 00007fff281a1501 R11:
ffff8809071340c0 R12: ffffffff812509d4
Dec  2 14:43:23 cap-x6270-01 kernel: R13: ffff88097b9a38c0 R14:
0000000000000246 R15: 0000000000000001
Dec  2 14:43:23 cap-x6270-01 kernel: FS:  00007f2c0e2006e0(0000)
GS:ffffc90001c00000(0000) knlGS:0000000000000000
Dec  2 14:43:23 cap-x6270-01 kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
0000000080050033
Dec  2 14:43:23 cap-x6270-01 kernel: CR2: 0000000020fe7000 CR3:
000000097b1b1000 CR4: 00000000000006e0
Dec  2 14:43:23 cap-x6270-01 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Dec  2 14:43:23 cap-x6270-01 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Dec  2 14:43:23 cap-x6270-01 kernel: Call Trace:
Dec  2 14:43:23 cap-x6270-01 kernel:  [<ffffffff81285a30>] ?
inet_csk_get_port+0x1b2/0x29e
Dec  2 14:43:23 cap-x6270-01 kernel:  [<ffffffff812a15e2>] ?
inet_bind+0x10c/0x1b7
Dec  2 14:43:23 cap-x6270-01 kernel:  [<ffffffff8124ef53>] ? sys_bind+0x6e/0x9e
Dec  2 14:43:23 cap-x6270-01 kernel:  [<ffffffff8106de14>] ?
audit_syscall_entry+0x1a4/0x1cf
Dec  2 14:43:23 cap-x6270-01 kernel:  [<ffffffff8100b92b>] ?
system_call_fastpath+0x16/0x1b

Either there are more places for race condition, or the fix didn't
address the issue effectively.

Regards,
Kapil
