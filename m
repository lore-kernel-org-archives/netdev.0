From: R Parameswaran <parameswaran.r7@gmail.com>
Subject: Re: [PATCH net-next v5 2/2] L2TP:Adjust intf MTU, add underlay L3, L2 hdrs.
Date: Tue, 11 Apr 2017 09:39:58 -0700
Message-ID: <CAGeBGG5EJ8zeyGEeOkr8HHx9dZ98veRYM2Reb_gqQp21pNgJmQ@mail.gmail.com>
References: <alpine.DEB.2.11.1704051650420.19131@vera98.eng.brocade.com> <20170411104048.2lef7jl4f4qxqct3@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        James Chapman <jchapman@katalix.com>, kleptog@svana.org,
        Nachi Prachanda <nprachan@brocade.com>,
        Robert Shearman <rshearma@brocade.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Sven-Thorsten Dietrich <sdietric@brocade.com>,
        Chas Williams III <ciwillia@brocade.com>,
        Luca Boccassi <lboccass@brocade.com>,
        Derek Fawcus <dfawcus@brocade.com>,
        Bill Hong <bhong@brocade.com>,
        Jan Blunck <jblunck@brocade.com>,
        David Miller <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170411104048.2lef7jl4f4qxqct3@alphalink.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guillaume,

On Tue, Apr 11, 2017 at 3:40 AM, Guillaume Nault <g.nault@alphalink.fr> wro=
te:
> On Wed, Apr 05, 2017 at 05:00:07PM -0700, R. Parameswaran wrote:
>>
>> Change-set here uses the new kernel function, kernel_sock_ip_overhead(),
>> to factor the outer IP overhead on the L2TP tunnel socket (including
>> IP Options, if any) when calculating the default MTU for an Ethernet
>> pseudowire, along with consideration of the inner Ethernet header.
>>
> I get the following warning with CONFIG_LOCKDEP when creating a new
> session:
> # ip l2tp add tunnel local 10.1.8.64 remote 10.1.8.32 udp_sport 1701 udp_=
dport 1701 tunnel_id 1 peer_tunnel_id 1
> # ip l2tp add session tunnel_id 1 session_id 1 peer_session_id 1
> ...

Thanks for reporting this - I'll try and put up a patch soon,
hopefully the patch can stay in while I add this. One Q - how many CPU
cores do you have? Can you give me some idea of how many tunnels and
sessions when you saw this?

I did not see this warning in my testing, possibly because
CONFIG_LOCKDEP_SUPPORT is turned off on the product build? Will
re-test with this turned on.

thanks,

Ramkumar

> [   45.524535] ------------[ cut here ]------------
> [   45.524570] WARNING: CPU: 3 PID: 732 at ./include/net/sock.h:1509 kern=
el_sock_ip_overhead+0x54/0x1a1
> [   45.524574] Modules linked in: l2tp_eth l2tp_netlink l2tp_core ip6_udp=
_tunnel udp_tunnel crc32c_intel ghash_clmulni_intel pcbc aesni_intel aes_x8=
6_64 crypto_simd cryptd glue_helper evdev acpi_cpufreq processor button ser=
io_raw ext4 crc16 jbd2 mbcache virtio_blk virtio_net virtio_pci virtio_ring=
 virtio
> [   45.524696] CPU: 3 PID: 732 Comm: ip Not tainted 4.11.0-rc5 #1
> [   45.524700] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S 1.10.2-1 04/01/2014
> [   45.524704] Call Trace:
> [   45.524714]  dump_stack+0x67/0x90
> [   45.524725]  __warn+0xfd/0x118
> [   45.524739]  warn_slowpath_null+0x18/0x1a
> [   45.524747]  kernel_sock_ip_overhead+0x54/0x1a1
> [   45.524761]  l2tp_eth_create+0x1eb/0x557 [l2tp_eth]
> [   45.524768]  ? __mutex_unlock_slowpath+0xb5/0x2c2
> [   45.524787]  ? l2tp_eth_dev_uninit+0xd9/0xd9 [l2tp_eth]
> [   45.524800]  l2tp_nl_cmd_session_create+0x521/0x56b [l2tp_netlink]
> [   45.524827]  genl_family_rcv_msg+0x445/0x4b3
> [   45.524857]  genl_rcv_msg+0x60/0x84
> [   45.524867]  ? genl_family_rcv_msg+0x4b3/0x4b3
> [   45.524875]  netlink_rcv_skb+0x95/0x102
> [   45.524881]  ? down_read+0x41/0x62
> [   45.524893]  genl_rcv+0x23/0x32
> [   45.524901]  netlink_unicast+0x1b0/0x23b
> [   45.524915]  netlink_sendmsg+0x46f/0x48f
> [   45.524933]  ? netlink_unicast+0x23b/0x23b
> [   45.524942]  sock_sendmsg_nosec+0x41/0x51
> [   45.524953]  sock_sendmsg+0x33/0x38
> [   45.524962]  ___sys_sendmsg+0x2a0/0x374
> [   45.524991]  ? do_raw_spin_unlock+0xc2/0xcc
> [   45.525002]  ? _raw_spin_unlock+0x22/0x25
> [   45.525014]  ? match_held_lock+0x20/0x113
> [   45.525027]  ? __fget_light+0x89/0xae
> [   45.525045]  __sys_sendmsg+0x40/0x6b
> [   45.525052]  ? __sys_sendmsg+0x40/0x6b
> [   45.525075]  SyS_sendmsg+0x9/0xb
> [   45.525083]  entry_SYSCALL_64_fastpath+0x18/0xad
> [   45.525089] RIP: 0033:0x7fb224391690
> [   45.525094] RSP: 002b:00007ffe53943dd8 EFLAGS: 00000246 ORIG_RAX: 0000=
00000000002e
> [   45.525104] RAX: ffffffffffffffda RBX: 00007ffe539480f0 RCX: 00007fb22=
4391690
> [   45.525108] RDX: 0000000000000000 RSI: 00007ffe53943e20 RDI: 000000000=
0000004
> [   45.525113] RBP: ffffffff810a1e49 R08: 0000000000000000 R09: 000000000=
0000005
> [   45.525119] R10: 0000000000000000 R11: 0000000000000246 R12: ffff88003=
436ff98
> [   45.525124] R13: 0000000000000046 R14: 00007ffe539486a0 R15: 00007ffe5=
3947ea0
> [   45.525136]  ? trace_hardirqs_off_caller+0x121/0x12f
> [   45.525157] ---[ end trace 0834023e7b30e761 ]---
>
> I guess you neet to lock_sock(tunnel->socket) before calling
> kernel_sock_ip_overhead().
