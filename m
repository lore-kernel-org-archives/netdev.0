From: f6bvp <f6bvp@free.fr>
Subject: [AX25] inconsistent lock state
Date: Thu, 16 Jun 2011 22:40:57 +0200
Message-ID: <4DFA6A59.2000709@free.fr>
References: <4B2CD772.1030106@upmc.fr> <4B2D1025.1020106@gmail.com> <4B2E6729.1090102@free.fr> <4B507FAA.8010007@free.fr> <20100115203654.GA3084@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.org>, linux-hams@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20100115203654.GA3084@del.dom.local>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

When unpluging ethernet connector a few seconds I observed the followin=
g=20
kernel message :


Jun 16 12:03:25 f6bvp-9 kernel: e1000e: eth1 NIC Link is Down
Jun 16 12:03:25 f6bvp-9 ifplugd(eth1)[1541]: Link beat lost.
Jun 16 12:03:31 f6bvp-9 ifplugd(eth1)[1541]: Executing=20
'/etc/ifplugd/ifplugd.action eth1 down'.
Jun 16 12:03:31 f6bvp-9 avahi-daemon[2197]: Withdrawing address record=20
for 192.168.0.66 on eth1.
Jun 16 12:03:31 f6bvp-9 avahi-daemon[2197]: Leaving mDNS multicast grou=
p=20
on interface eth1.IPv4 with address 192.168.0.66.
Jun 16 12:03:31 f6bvp-9 avahi-daemon[2197]: Interface eth1.IPv4 no=20
longer relevant for mDNS.
Jun 16 12:03:31 f6bvp-9 avahi-daemon[2197]: Withdrawing address record=20
for fe80::21c:c0ff:fe36:723e on eth1.
Jun 16 12:03:31 f6bvp-9 vnstatd[2022]: SIGHUP received, flushing data t=
o=20
disk and reloading config.
Jun 16 12:03:31 f6bvp-9 ifplugd(eth1)[1541]: client: Rechargement de la=
=20
configuration de vnstatd=C2 : #033[65G[#033[1;32m  OK  #033[0;39m]#015
Jun 16 12:03:31 f6bvp-9 ifplugd(eth1)[1541]: Program executed successfu=
lly.
Jun 16 12:03:31 f6bvp-9 kernel: ADDRCONF(NETDEV_UP): eth1: link is not =
ready
Jun 16 12:03:34 f6bvp-9 kernel:
Jun 16 12:03:34 f6bvp-9 kernel: =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Jun 16 12:03:34 f6bvp-9 kernel: [ INFO: inconsistent lock state ]
Jun 16 12:03:34 f6bvp-9 kernel: 2.6.39.1 #3
Jun 16 12:03:34 f6bvp-9 kernel: ---------------------------------
Jun 16 12:03:34 f6bvp-9 kernel: inconsistent {IN-SOFTIRQ-R} ->=20
{SOFTIRQ-ON-W} usage.
Jun 16 12:03:34 f6bvp-9 kernel: ax25ipd/2813 [HC0[0]:SC0[0]:HE1:SE1] ta=
kes:
Jun 16 12:03:34 f6bvp-9 kernel: (disc_data_lock){+++?.-}, at:=20
[<ffffffffa018552b>] mkiss_close+0x1b/0x90 [mkiss]
Jun 16 12:03:34 f6bvp-9 kernel: {IN-SOFTIRQ-R} state was registered at:
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff8109484e>]=20
__lock_acquire+0x57e/0x14c0
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff81095836>]=20
lock_acquire+0xa6/0x160
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff813f64f4>]=20
_raw_read_lock+0x34/0x50
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffffa01850ed>]=20
mkiss_get+0x1d/0x50 [mkiss]
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffffa018517e>]=20
mkiss_write_wakeup+0x1e/0xb0 [mkiss]
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff8129457e>] tty_wakeup+0x6e/0=
x80
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff8129f243>] pty_write+0x73/0x=
80
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffffa0185d2e>]=20
ax_xmit+0x27e/0x5e0 [mkiss]
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff81339dac>]=20
dev_hard_start_xmit+0x34c/0x6f0
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff81358b4d>]=20
sch_direct_xmit+0xdd/0x260
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff8133cc8f>]=20
dev_queue_xmit+0x1af/0x8a0
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffffa0325072>]=20
ax25_queue_xmit+0x52/0x60 [ax25]
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffffa032516f>]=20
ax25_transmit_buffer+0xef/0x130 [ax25]
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffffa0325238>]=20
ax25_send_iframe+0x88/0xe0 [ax25]
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffffa032536e>]=20
ax25_kick+0xde/0x220 [ax25]
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffffa0326715>]=20
ax25_std_frame_in+0x65/0x920 [ax25]
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffffa03241da>]=20
ax25_rcv+0x3aa/0x9a0 [ax25]
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffffa032486f>]=20
ax25_kiss_rcv+0x9f/0xb0 [ax25]
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff8133bba5>]=20
__netif_receive_skb+0x205/0x6d0
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff8133c144>]=20
process_backlog+0xd4/0x1e0
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff8133c995>]=20
net_rx_action+0x125/0x270
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff810618f1>]=20
__do_softirq+0xc1/0x210
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff813ffa9c>] call_softirq+0x1c=
/0x30
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff810627db>]=20
local_bh_enable_ip+0xeb/0xf0
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff813f6594>]=20
_raw_spin_unlock_bh+0x34/0x40
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffffa0186522>]=20
mkiss_receive_buf+0x2e2/0x3dc [mkiss]
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff8129e122>]=20
flush_to_ldisc+0x1b2/0x1d0
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff810762c0>]=20
process_one_work+0x1a0/0x510
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff81078ba2>]=20
worker_thread+0x172/0x400
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff8107d816>] kthread+0xb6/0xc0
Jun 16 12:03:34 f6bvp-9 kernel:  [<ffffffff813ff9a4>]=20
kernel_thread_helper+0x4/0x10
Jun 16 12:03:34 f6bvp-9 kernel: irq event stamp: 76635461
Jun 16 12:03:34 f6bvp-9 kernel: hardirqs last  enabled at (76635461):=20
[<ffffffff813f6620>] _raw_spin_unlock_irqrestore+0x40/0x70
Jun 16 12:03:34 f6bvp-9 kernel: hardirqs last disabled at (76635460):=20
[<ffffffff813f5f1e>] _raw_spin_lock_irqsave+0x2e/0x70
Jun 16 12:03:34 f6bvp-9 kernel: softirqs last  enabled at (76635394):=20
[<ffffffff81329337>] sk_common_release+0x67/0xd0
Jun 16 12:03:34 f6bvp-9 kernel: softirqs last disabled at (76635392):=20
[<ffffffff813f60f6>] _raw_write_lock_bh+0x16/0x50
Jun 16 12:03:34 f6bvp-9 kernel:
Jun 16 12:03:34 f6bvp-9 kernel: other info that might help us debug thi=
s:
Jun 16 12:03:34 f6bvp-9 kernel: 2 locks held by ax25ipd/2813:
Jun 16 12:03:34 f6bvp-9 kernel: #0:  (big_tty_mutex){+.+.+.}, at:=20
[<ffffffff813f67ce>] tty_lock+0x2e/0x4f
Jun 16 12:03:34 f6bvp-9 kernel: #1:  (&tty->ldisc_mutex){+.+.+.}, at:=20
[<ffffffff8129d597>] tty_ldisc_hangup+0xe7/0x250
Jun 16 12:03:34 f6bvp-9 kernel:
Jun 16 12:03:34 f6bvp-9 kernel: stack backtrace:
Jun 16 12:03:34 f6bvp-9 kernel: Pid: 2813, comm: ax25ipd Not tainted=20
2.6.39.1 #3
Jun 16 12:03:34 f6bvp-9 kernel: Call Trace:
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff81092dc0>]=20
print_usage_bug+0x170/0x180
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff81093a81>] mark_lock+0x211/0x=
3f0
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff810948c4>]=20
__lock_acquire+0x5f4/0x14c0
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff81093ccb>] ?=20
mark_held_locks+0x6b/0xa0
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff813f65d0>] ?=20
_raw_spin_unlock_irq+0x30/0x40
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff81093fcd>] ?=20
trace_hardirqs_on_caller+0x13d/0x180
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff81095836>] lock_acquire+0xa6/=
0x160
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffffa018552b>] ?=20
mkiss_close+0x1b/0x90 [mkiss]
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff81093ccb>] ?=20
mark_held_locks+0x6b/0xa0
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff813f6221>]=20
_raw_write_lock+0x31/0x40
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffffa018552b>] ?=20
mkiss_close+0x1b/0x90 [mkiss]
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8113775e>] ?=20
kmem_cache_alloc_trace+0x7e/0x140
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffffa018552b>]=20
mkiss_close+0x1b/0x90 [mkiss]
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8129c84b>]=20
tty_ldisc_close+0x4b/0x70
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8129ce90>]=20
tty_ldisc_reinit+0x40/0x80
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8129d5b4>]=20
tty_ldisc_hangup+0x104/0x250
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8129588c>]=20
__tty_hangup+0x15c/0x3e0
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8109401d>] ?=20
trace_hardirqs_on+0xd/0x10
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff81295b3e>] tty_vhangup+0xe/0x=
10
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8129f37e>] pty_close+0x10e/0x=
160
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff81295ceb>] tty_release+0x16b/=
0x640
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8113920a>] ?=20
kmem_cache_free+0x11a/0x160
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff81142f9a>] fput+0xea/0x230
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8113ee03>] filp_close+0x63/0x=
90
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8105dab1>]=20
put_files_struct+0x171/0x190
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8105d978>] ?=20
put_files_struct+0x38/0x190
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8105db22>] exit_files+0x52/0x=
60
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8105deb9>] do_exit+0x189/0x86=
0
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff81142cc0>] ? fget+0xd0/0xd0
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff813f69b9>] ?=20
retint_swapgs+0x13/0x1b
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8105e5eb>] do_group_exit+0x5b=
/0xd0
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff8105e677>]=20
sys_exit_group+0x17/0x20
Jun 16 12:03:34 f6bvp-9 kernel: [<ffffffff813fe812>]=20
system_call_fastpath+0x16/0x1b

Kernel is 2.6.39.1

Is there something wrong in AX25 code or (more unlikely) is this=20
operation not permitted ?
Thanks for help.

Bernard Pidoux


--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
