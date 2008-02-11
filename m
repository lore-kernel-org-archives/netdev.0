From: Jiri Slaby <jirislaby@gmail.com>
Subject: [BUG] bad address in twothirdsMD4Transform
Date: Mon, 11 Feb 2008 20:29:36 +0100
Message-ID: <47B0A220.8040400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:23357 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760610AbYBKT3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 14:29:40 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3894972fga.17
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 11:29:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I get this with 32 bit Firefox 3b2 and java 1.6.0_03 on 64 bit:

BUG: unable to handle kernel paging request at ffff8102366213f8
IP: [<ffffffff803558f4>] twothirdsMD4Transform+0xc4/0x3b0
PGD 8063 PUD 0
Oops: 0000 [1] SMP
last sysfs file: /sys/devices/virtual/net/tun0/statistics/collisions
CPU 1
Modules linked in: szetest szedata2 v4l2_extension videodev v4l2_common 
v4l1_compat isofs tun bitrev ipv6 arc4 ecb crypto_blkcipher cryptomgr 
crypto_algapi ath5k mac80211 cfg80211 rtc_cmos sr_mod rtc_core ehci_hcd floppy 
rtc_lib cdrom crc32 [last unloaded: szedata2]
Pid: 3512, comm: java_vm Not tainted 2.6.24-mm1_64 #380
RIP: 0010:[<ffffffff803558f4>]  [<ffffffff803558f4>] 
twothirdsMD4Transform+0xc4/0x3b0
RSP: 0000:ffff810042721c68  EFLAGS: 00010286
RAX: 0000000000004000 RBX: 0000000000000000 RCX: 000000003ffffffc
RDX: 000000007cfbfdc8 RSI: ffff810042721cd8 RDI: ffff8100435893d0
RBP: ffff810042721cc8 R08: 0000000080000000 R09: 0000000000000000
R10: ffff8101ac7c033c R11: 0000000000000000 R12: 0000000067f18b72
R13: 0000000000000000 R14: ffff8100435893b0 R15: 00000000c42802a9
FS:  0000000000000000(0000) GS:ffff81007d008500(0063) knlGS:00000000f492ab90
CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
CR2: ffff8102366213f8 CR3: 00000000426e6000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process java_vm (pid: 3512, threadinfo ffff810042720000, task ffff81002211b6b0)
Stack:  ffff81007c0c62d0 000000007cfbfdc8 000000002dc63fea 0000000001000000
  0000000000000000 0000000000000000 0000000000000000 0000000000000000
  ffff8100435893b0 ffff810043588d80 ffff8100435893b0 ffff810042721e88
Call Trace:
  [<ffffffff80356cce>] secure_tcpv6_sequence_number+0x6e/0xa0
  [<ffffffff880b24ff>] :ipv6:tcp_v6_connect+0x4bf/0x650
  [<ffffffff80466a89>] ? lock_sock_nested+0xc9/0xe0
  [<ffffffff804b68d1>] inet_stream_connect+0x231/0x2c0
  [<ffffffff804a5efe>] ? tcp_init_xmit_timers+0x1e/0x20
  [<ffffffff802b96aa>] ? inotify_d_instantiate+0x1a/0x50
  [<ffffffff80464171>] sys_connect+0x71/0xa0
  [<ffffffff8046449a>] ? sock_map_fd+0x4a/0x70
  [<ffffffff80480f56>] compat_sys_socketcall+0x86/0x1b0
  [<ffffffff80224302>] ia32_sysret+0x0/0xa


Code: 56 10 c1 c8 0d 48 89 55 b0 03 0c 96 44 89 ca 44 31 c2 21 c2 44 31 c2 01 d1 
8b 56 14 c1 c9 1d 48 89 55 a8 44 8b 7e 18 44 8b 66 1c <44> 03 04 96 89 c2 44 31 
ca 21 ca 44 31 ca 46 03 0c be 41 01 d0
RIP  [<ffffffff803558f4>] twothirdsMD4Transform+0xc4/0x3b0
  RSP <ffff810042721c68>
CR2: ffff8102366213f8
---[ end trace 057610ccf9ee39f0 ]---

Reproducible, going to
https://www.mojebanka.cz/InternetBanking/JSPLogin.jsp?L=CS
triggers it.
