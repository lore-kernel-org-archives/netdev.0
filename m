From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: [PATCH net] ppp: don't override =?UTF-8?Q?sk-=3Esk=5Fstate=20?=
 =?UTF-8?Q?in=20pppoe=5Fflush=5Fdev=28=29?=
Date: Fri, 02 Oct 2015 11:01:45 +0300
Message-ID: <7045c1dad4647944f61c958511d45fcd@visp.net.lb>
References: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>,
	Oleksii Berezhniak <core@irc.lg.ua>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:55650 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbbJBIBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 04:01:53 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 49FB2480638
	for <netdev@vger.kernel.org>; Fri,  2 Oct 2015 11:01:47 +0300 (EEST)
In-Reply-To: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is similar panic after patch applied (it might be different bug), 
got over netconsole:

  [126348.610996] BUG: unable to handle kernel
  NULL pointer dereference
  at 0000000000000428
  [126348.611656] IP:
  [<ffffffffa00ea129>] pppoe_release+0x56/0x142 [pppoe]
  [126348.612033] PGD 17d0b03067
  PUD 17c721b067
  PMD 0

  [126348.612545] Oops: 0000 [#1]
  SMP

  [126348.612981] Modules linked in:
  act_skbedit
  sch_fq
  cls_fw
  act_police
  cls_u32
  sch_ingress
  sch_sfq
  sch_htb
  pppoe
  pppox
  ppp_generic
  slhc
  netconsole
  configfs
  xt_nat
  ts_bm
  xt_string
  xt_connmark
  xt_TCPMSS
  xt_tcpudp
  xt_mark
  iptable_filter
  iptable_nat
  nf_conntrack_ipv4
  nf_defrag_ipv4
  nf_nat_ipv4
  nf_nat
  nf_conntrack
  iptable_mangle
  ip_tables
  x_tables
  8021q
  garp
  mrp
  stp
  llc
  bonding

  [126348.617115] CPU: 0 PID: 5254 Comm: accel-pppd Not tainted 
4.2.2-build-0087 #2
  [126348.617632] Hardware name: Intel Corporation S2600GZ/S2600GZ, BIOS 
SE5C600.86B.02.03.0003.041920141333 04/19/2014
  [126348.618193] task: ffff8817cfbe0000 ti: ffff8817c6350000 task.ti: 
ffff8817c6350000
  [126348.618696] RIP: 0010:[<ffffffffa00ea129>]
  [<ffffffffa00ea129>] pppoe_release+0x56/0x142 [pppoe]
  [126348.619306] RSP: 0018:ffff8817c6353e28  EFLAGS: 00010202
  [126348.619601] RAX: 0000000000000000 RBX: ffff8817a92b0400 RCX: 
0000000000000000
  [126348.620152] RDX: 0000000000000001 RSI: 00000000fffffe01 RDI: 
ffffffff8180c18a
  [126348.620715] RBP: ffff8817c6353e68 R08: 0000000000000000 R09: 
0000000000000000
  [126348.621254] R10: ffff88173c02b210 R11: 0000000000000293 R12: 
ffff8817b3c18000
  [126348.621784] R13: ffff8817b3c18030 R14: ffff8817967f1140 R15: 
ffff8817d226c920
  [126348.622330] FS:  00007f9444db9700(0000) GS:ffff8817dee00000(0000) 
knlGS:0000000000000000
  [126348.622876] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  [126348.623202] CR2: 0000000000000428 CR3: 00000017c70b2000 CR4: 
00000000001406f0
  [126348.623760] Stack:
  [126348.624056]  0000000100200018
  0000000000000000
  0000000100000000
  ffff8817b3c18000

  [126348.624925]  ffffffffa00ec280
  ffff8817b3c18030
  ffff8817967f1140
  ffff8817d226c920

  [126348.625736]  ffff8817c6353e88
  ffffffff8180820a
  ffff88173c02b200
  0000000000000008

  [126348.626533] Call Trace:
  [126348.626873]  [<ffffffff8180820a>] sock_release+0x1a/0x70
  [126348.627183]  [<ffffffff8180826d>] sock_close+0xd/0x11
  [126348.627512]  [<ffffffff81152c61>] __fput+0xdf/0x193
  [126348.627845]  [<ffffffff81152d43>] ____fput+0x9/0xb
  [126348.628169]  [<ffffffff810d098e>] task_work_run+0x78/0x8f
  [126348.628517]  [<ffffffff810038a9>] do_notify_resume+0x40/0x4e
  [126348.628837]  [<ffffffff818a5a0a>] int_signal+0x12/0x17
  [126348.629131] Code:
  48
  8b
  83
  e0
  00
  00
  00
  a8
  01
  74
  12
  48
  89
  df
  e8
  0d
  24
  72
  e1
  b8
  f7
  ff
  ff
  ff
  e9
  eb
  00
  00
  00
  8a
  43
  12
  a8
  0b
  74
  1c
  48
  8b
  83
  a0
  02
  00
  00

  8b
  80
  28
  04
  00
  00
  65
  ff
  08
  48
  c7
  83
  a0
  02
  00
  00
  00
  00
  00
  00

  [126348.635060] RIP
  [<ffffffffa00ea129>] pppoe_release+0x56/0x142 [pppoe]
  [126348.635432]  RSP <ffff8817c6353e28>
  [126348.635718] CR2: 0000000000000428
  [126348.641165] ---[ end trace 911ff90a1416e3d1 ]---
  [126348.653235] Kernel panic - not syncing: Fatal exception
  [126348.653538] Kernel Offset: disabled
  [126348.677177] Rebooting in 5 seconds..




On 2015-09-30 12:45, Guillaume Nault wrote:
> Since commit 2b018d57ff18 ("pppoe: drop PPPOX_ZOMBIEs in 
> pppoe_release"),
> pppoe_release() calls dev_put(po->pppoe_dev) if sk is in the
> PPPOX_ZOMBIE state. But pppoe_flush_dev() can set sk->sk_state to
> PPPOX_ZOMBIE _and_ reset po->pppoe_dev to NULL. This leads to the
> following oops:
> 
> [  570.140800] BUG: unable to handle kernel NULL pointer dereference
> at 00000000000004e0
> [  570.142931] IP: [<ffffffffa018c701>] pppoe_release+0x50/0x101 
> [pppoe]
> [  570.144601] PGD 3d119067 PUD 3dbc1067 PMD 0
> [  570.144601] Oops: 0000 [#1] SMP
> [  570.144601] Modules linked in: l2tp_ppp l2tp_netlink l2tp_core
> ip6_udp_tunnel udp_tunnel pppoe pppox ppp_generic slhc loop
> crc32c_intel ghash_clmulni_intel jitterentropy_rng sha256_generic hmac
> drbg ansi_cprng aesni_intel aes_x86_64 ablk_helper cryptd lrw gf128mul
> glue_helper acpi_cpufreq evdev serio_raw processor button ext4 crc16
> mbcache jbd2 virtio_net virtio_blk virtio_pci virtio_ring virtio
> [  570.144601] CPU: 1 PID: 15738 Comm: ppp-apitest Not tainted 4.2.0 #1
> [  570.144601] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS Debian-1.8.2-1 04/01/2014
> [  570.144601] task: ffff88003d30d600 ti: ffff880036b60000 task.ti:
> ffff880036b60000
> [  570.144601] RIP: 0010:[<ffffffffa018c701>]  [<ffffffffa018c701>]
> pppoe_release+0x50/0x101 [pppoe]
> [  570.144601] RSP: 0018:ffff880036b63e08  EFLAGS: 00010202
> [  570.144601] RAX: 0000000000000000 RBX: ffff880034340000 RCX: 
> 0000000000000206
> [  570.144601] RDX: 0000000000000006 RSI: ffff88003d30dd20 RDI: 
> ffff88003d30dd20
> [  570.144601] RBP: ffff880036b63e28 R08: 0000000000000001 R09: 
> 0000000000000000
> [  570.144601] R10: 00007ffee9b50420 R11: ffff880034340078 R12: 
> ffff8800387ec780
> [  570.144601] R13: ffff8800387ec7b0 R14: ffff88003e222aa0 R15: 
> ffff8800387ec7b0
> [  570.144601] FS:  00007f5672f48700(0000) GS:ffff88003fc80000(0000)
> knlGS:0000000000000000
> [  570.144601] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  570.144601] CR2: 00000000000004e0 CR3: 0000000037f7e000 CR4: 
> 00000000000406a0
> [  570.144601] Stack:
> [  570.144601]  ffffffffa018f240 ffff8800387ec780 ffffffffa018f240
> ffff8800387ec7b0
> [  570.144601]  ffff880036b63e48 ffffffff812caabe ffff880039e4e000
> 0000000000000008
> [  570.144601]  ffff880036b63e58 ffffffff812cabad ffff880036b63ea8
> ffffffff811347f5
> [  570.144601] Call Trace:
> [  570.144601]  [<ffffffff812caabe>] sock_release+0x1a/0x75
> [  570.144601]  [<ffffffff812cabad>] sock_close+0xd/0x11
> [  570.144601]  [<ffffffff811347f5>] __fput+0xff/0x1a5
> [  570.144601]  [<ffffffff811348cb>] ____fput+0x9/0xb
> [  570.144601]  [<ffffffff81056682>] task_work_run+0x66/0x90
> [  570.144601]  [<ffffffff8100189e>] prepare_exit_to_usermode+0x8c/0xa7
> [  570.144601]  [<ffffffff81001a26>] 
> syscall_return_slowpath+0x16d/0x19b
> [  570.144601]  [<ffffffff813babb1>] int_ret_from_sys_call+0x25/0x9f
> [  570.144601] Code: 48 8b 83 c8 01 00 00 a8 01 74 12 48 89 df e8 8b
> 27 14 e1 b8 f7 ff ff ff e9 b7 00 00 00 8a 43 12 a8 0b 74 1c 48 8b 83
> a8 04 00 00 <48> 8b 80 e0 04 00 00 65 ff 08 48 c7 83 a8 04 00 00 00 00
> 00 00
> [  570.144601] RIP  [<ffffffffa018c701>] pppoe_release+0x50/0x101 
> [pppoe]
> [  570.144601]  RSP <ffff880036b63e08>
> [  570.144601] CR2: 00000000000004e0
> [  570.200518] ---[ end trace 46956baf17349563 ]---
> 
> pppoe_flush_dev() has no reason to override sk->sk_state with
> PPPOX_ZOMBIE. pppox_unbind_sock() already sets sk->sk_state to
> PPPOX_DEAD, which is the correct state given that sk is unbound and
> po->pppoe_dev is NULL.
> 
> Fixes: 2b018d57ff18 ("pppoe: drop PPPOX_ZOMBIEs in pppoe_release")
> Tested-by: Oleksii Berezhniak <core@irc.lg.ua>
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> ---
>  drivers/net/ppp/pppoe.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
> index 3837ae3..2ed7506 100644
> --- a/drivers/net/ppp/pppoe.c
> +++ b/drivers/net/ppp/pppoe.c
> @@ -313,7 +313,6 @@ static void pppoe_flush_dev(struct net_device *dev)
>  			if (po->pppoe_dev == dev &&
>  			    sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND | PPPOX_ZOMBIE)) 
> {
>  				pppox_unbind_sock(sk);
> -				sk->sk_state = PPPOX_ZOMBIE;
>  				sk->sk_state_change(sk);
>  				po->pppoe_dev = NULL;
>  				dev_put(dev);
