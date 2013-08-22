From: Udo Steinberg <udo@hypervisor.org>
Subject: Null pointer dereference in nl80211_set_reg
Date: Thu, 22 Aug 2013 17:41:21 +0200
Message-ID: <20130822174121.18441b7f@x220>
Reply-To: udo@hypervisor.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/t2LusJ15ll.IBpE23RKUUHG"; protocol="application/pgp-signature"
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Network Mailing List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/t2LusJ15ll.IBpE23RKUUHG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

I'm running Linux 3.10.7 and have encountered the following NULL pointer
dereference. So far it has only occurred once, so I cannot reproduce the
circumstances that cause the problem.

Please keep me on CC: as I'm not subscribed to LKML.

Cheers,
Udo

cfg80211: Calling CRDA for country: DE
cfg80211: Regulatory domain changed to country: DE
cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eir=
p)
cfg80211:   (2400000 KHz - 2483500 KHz @ 40000 KHz), (N/A, 2000 mBm)
cfg80211:   (5150000 KHz - 5350000 KHz @ 40000 KHz), (N/A, 2000 mBm)
cfg80211:   (5470000 KHz - 5725000 KHz @ 40000 KHz), (N/A, 2698 mBm)
wlan0: Limiting TX power to 18 (20 - 2) dBm as advertised by 00:24:6c:2b:18=
:22
wlan0: authenticate with 00:24:6c:2b:17:32
wlan0: send auth to 00:24:6c:2b:17:32 (try 1/3)
cfg80211: Calling CRDA to update world regulatory domain
wlan0: authenticated
wlan0: waiting for beacon from 00:24:6c:2b:17:32
BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<ffffffff8140d989>] nl80211_set_reg+0xcc/0x1ff
PGD 20177e067 PUD 2127c6067 PMD 0=20
Oops: 0000 [#1] PREEMPT SMP=20
CPU: 2 PID: 2465 Comm: crda Not tainted 3.10.7 #1
Hardware name: LENOVO 4290W4H/4290W4H, BIOS 8DET69WW (1.39 ) 07/18/2013
task: ffff880214ecd040 ti: ffff880212764000 task.ti: ffff880212764000
RIP: 0010:[<ffffffff8140d989>]  [<ffffffff8140d989>] nl80211_set_reg+0xcc/0=
x1ff
RSP: 0018:ffff880212765ab8  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff880214f8f6c0 RCX: 0000000000000000
RDX: ffff88021d002348 RSI: 0000000000000012 RDI: 0000000000000000
RBP: ffff880214f8f6c0 R08: ffff880214f8f6c0 R09: ffff880214413014
R10: 0001000800000034 R11: 0002000800000180 R12: 0000000000000000
R13: ffff880212765b28 R14: ffff880214413014 R15: ffff880214413000
FS:  00007fa95007b740(0000) GS:ffff88021e280000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 00000001f649f000 CR4: 00000000000407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
 0000000000000000 ffff88021441301c 0000000000000108 ffff880215560000
 00000000000000b4 ffffffff811945d7 ffffffff8167ca80 ffffffff8185b6c0
 ffffffff8185ab58 ffff880215560000 ffff880214eb9ec0 0000000000000004
Call Trace:
 [<ffffffff811945d7>] ? nla_parse+0x8b/0xb4
 [<ffffffff813beda3>] ? genl_rcv_msg+0x1be/0x230
 [<ffffffff813bebe5>] ? genl_unlock_all+0x11/0x11
 [<ffffffff813bea1e>] ? netlink_rcv_skb+0x40/0x89
 [<ffffffff8139ec22>] ? __kmalloc_reserve.isra.31+0x1e/0x56
 [<ffffffff813beb9e>] ? genl_rcv+0x1f/0x2c
 [<ffffffff813bd960>] ? netlink_unicast+0xe5/0x16b
 [<ffffffff813bdf7a>] ? netlink_sendmsg+0x275/0x2b6
 [<ffffffff81399926>] ? sock_sendmsg+0x6d/0x80
 [<ffffffff81087ece>] ? __alloc_pages_nodemask+0xe9/0x773
 [<ffffffff810829b5>] ? find_get_page+0x6b/0x73
 [<ffffffff81399ab6>] ? ___sys_sendmsg+0x17d/0x1f4
 [<ffffffff8109b90f>] ? handle_pte_fault+0x125/0x687
 [<ffffffff81020585>] ? __do_page_fault+0x2cd/0x3b9
 [<ffffffff8100a3b7>] ? syscall_trace_leave+0xe0/0xe9
 [<ffffffff8139aa60>] ? __sys_sendmsg+0x39/0x5a
 [<ffffffff8145bf89>] ? tracesys+0xd0/0xd5
Code: 8a 46 04 88 43 14 41 8a 46 05 88 43 15 e8 4b b5 ff ff 84 c0 74 04 44 =
88 63 16 49 8b 45 20 48 89 dd 45 31 e4 48 8b 80 10 01 00 00 <44> 0f b7 30 4=
c 8d 68 04 41 83 ee 04 41 83 fe 03 0f 8e c1 00 00=20
RIP  [<ffffffff8140d989>] nl80211_set_reg+0xcc/0x1ff
 RSP <ffff880212765ab8>
CR2: 0000000000000000
---[ end trace 2ba935cb5e4d0137 ]---

--Sig_/t2LusJ15ll.IBpE23RKUUHG
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iEYEARECAAYFAlIWMSIACgkQnhRzXSM7nSknaQCfbL7czABEk59BTcEDdm0RpNgM
0LAAnjgeiKhc/9T7L6bTuQZpCK8OAu1A
=sR76
-----END PGP SIGNATURE-----

--Sig_/t2LusJ15ll.IBpE23RKUUHG--
