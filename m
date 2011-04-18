From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 33502] New: Caught 64-bit read from uninitialized memory
 in __alloc_skb
Date: Mon, 18 Apr 2011 08:30:41 -0700
Message-ID: <20110418083041.5ca1a92d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50205 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753692Ab1DRPao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 11:30:44 -0400
Received: from nehalam (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p3IFUgbM018808
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 08:30:44 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 17 Apr 2011 19:29:39 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 33502] New: Caught 64-bit read from uninitialized memory in __alloc_skb


https://bugzilla.kernel.org/show_bug.cgi?id=33502

           Summary: Caught 64-bit read from uninitialized memory in
                    __alloc_skb
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.39-rc3
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: casteyde.christian@free.fr
        Regression: Yes


Acer Aspire 1511LMi
Athlon 64 3GHz in 64bits mode
Slackware 64 13.1

Since 2.6.39-rc3 with kmemcheck enabled, I get the following warning:
...
pcmcia_socket pcmcia_socket0: cs: memory probe 0x0c0000-0x0fffff: excluding
0xc0000-0xfffff
pcmcia_socket pcmcia_socket0: cs: memory probe 0x60000000-0x60ffffff: excluding
0x60000000-0x
60ffffff
pcmcia_socket pcmcia_socket0: cs: memory probe 0xa0000000-0xa0ffffff: excluding
0xa0000000-0x
a0ffffff
udev: renamed network interface wlan0 to eth1
WARNING: kmemcheck: Caught 64-bit read from uninitialized memory
(ffff88001b0bb800)
00b00b1b0088ffff0000000000000000cafe1dea20009b0000299a3100000000
 u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u
 ^

Pid: 1511, comm: udevd Not tainted 2.6.39-rc3 #1 Acer,Inc. Aspire 1510  /Aspire
1510
RIP: 0010:[<ffffffff810c2f0c>]  [<ffffffff810c2f0c>]
__kmalloc_track_caller+0xbc/0x1d0
RSP: 0018:ffff88001d3a7a18  EFLAGS: 00010246
RAX: 0000000000000000 RBX: 0000000000000010 RCX: 000000000000284f
RDX: 000000000000284e RSI: ffff88001fe5b160 RDI: ffffffff8177e39a
RBP: ffff88001d3a7a48 R08: 0000000000000000 R09: ffff88001b931100
R10: 0000000000000000 R11: 0000000000000003 R12: ffff88001b0bb800
R13: ffff88001f803840 R14: 00000000000004d0 R15: ffffffff814769c6
FS:  00007f6ee81f1700(0000) GS:ffffffff81a1b000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff88001d0b3938 CR3: 000000001d38b000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
 [<ffffffff8147ccf2>] __alloc_skb+0x72/0x190
 [<ffffffff814769c6>] sock_alloc_send_pskb+0x236/0x3a0
 [<ffffffff81476b40>] sock_alloc_send_skb+0x10/0x20
 [<ffffffff81523c18>] unix_dgram_sendmsg+0x298/0x770
 [<ffffffff814715f3>] sock_sendmsg+0xe3/0x110
 [<ffffffff81472603>] sys_sendmsg+0x243/0x3c0
 [<ffffffff815e7238>] system_call_fastpath+0x16/0x1b
 [<ffffffffffffffff>] 0xffffffffffffffff
Adding 506012k swap on /dev/sda1.  Priority:-1 extents:1 across:506012k 
EXT4-fs (sda2): re-mounted. Opts: (null)
EXT4-fs (sda2): re-mounted. Opts: (null)
EXT3-fs: barriers not enabled
kjournald starting.  Commit interval 5 seconds
EXT3-fs (sda3): using internal journal
EXT3-fs (sda3): mounted filesystem with writeback data mode
b43-phy0: Loading firmware version 478.104 (2008-07-01 00:50:23)
ADDRCONF(NETDEV_UP): eth1: link is not ready
b43-phy0: Loading firmware version 478.104 (2008-07-01 00:50:23)
...

I cannot build 2.6.39-rc2, and in 2.6.39-rc1 I used to have another warning but
not this one.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
