From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: Re: oops in skb_under_panic with linux-next
Date: Wed, 21 May 2008 12:55:10 +0200
Message-ID: <20080521105510.GA14171@alice>
References: <20080520174912.GA6231@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:34801 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755220AbYEUKzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 06:55:35 -0400
Content-Disposition: inline
In-Reply-To: <20080520174912.GA6231@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Sesterhenn (snakebyte@gmx.de) wrote:
> hi,
> 
> i saw the following oops with linux-next from today
> running icmpv6fuzz -r  2187
> I was able to reproduce this, but didnt try rebooting and reproducing
> since i am currently not at home

i triggered this bug again with todays -git, but not 
sure yet on how to reproduce this reliably.

[ 3504.409219] icmpv6: msg of unknown type
[ 3504.599537] skb_under_panic: text:c056d0b7 len:2083 put:864
head:c91e33b0 data:c91e3150 tail:0xc91e34b0 end:0xc91e34b0 dev:<NULL>
[ 3504.614505] ------------[ cut here ]------------
[ 3504.614630] kernel BUG at net/core/skbuff.c:149!
[ 3504.614707] invalid opcode: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
[ 3504.614931] Modules linked in: nfsd exportfs
[ 3504.615130] 
[ 3504.615196] Pid: 1848, comm: icmpv6fuzz Not tainted
(2.6.26-rc3-00243-gd40ace0 #26)
[ 3504.615317] EIP: 0060:[<c04cff7c>] EFLAGS: 00010282 CPU: 0
[ 3504.615354] EIP is at skb_under_panic+0x5c/0x60
[ 3504.615354] EAX: 00000088 EBX: c91e33b0 ECX: 10000000 EDX: 00000000
[ 3504.615354] ESI: 00000000 EDI: c9aadd70 EBP: c91d4c30 ESP: c91d4c04
[ 3504.615354]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[ 3504.615354] Process icmpv6fuzz (pid: 1848, ti=c91d4000 task=ca885e80
task.ti=c91d4000)
[ 3504.615354] Stack: c076f8f0 c056d0b7 00000823 00000360 c91e33b0
c91e3150 c91e34b0 c91e34b0 
[ 3504.615354]        c0738473 c9aab0e0 c92c612c c91d4c3c c04d0f8a
c91d4cb3 c91d4c58 c056d0b7 
[ 3504.615354]        00000000 ca885e80 00000000 cedd8e04 c9aadd70
c91d4c80 c056d1f5 c92c612c 
[ 3504.615354] Call Trace:
[ 3504.615354]  [<c056d0b7>] ? ipv6_push_exthdr+0x27/0x60
[ 3504.615354]  [<c04d0f8a>] ? skb_push+0x2a/0x40
[ 3504.615354]  [<c056d0b7>] ? ipv6_push_exthdr+0x27/0x60
[ 3504.615354]  [<c056d1f5>] ? ipv6_push_nfrag_opts+0xd5/0xf0
[ 3504.615354]  [<c054ba05>] ? ip6_push_pending_frames+0x1e5/0x410
[ 3504.615354]  [<c056119c>] ? rawv6_sendmsg+0xa8c/0xce0
[ 3504.615354]  [<c017a131>] ? check_bytes_and_report+0x21/0xc0
[ 3504.615354]  [<c0179e13>] ? slab_pad_check+0x73/0x110
[ 3504.615354]  [<c0521a84>] ? inet_sendmsg+0x34/0x60
[ 3504.615354]  [<c04cb1c4>] ? sock_sendmsg+0xc4/0xf0
[ 3504.615354]  [<c017b553>] ? __slab_free+0x63/0x2e0
[ 3504.615354]  [<c0138190>] ? autoremove_wake_function+0x0/0x40
[ 3504.615354]  [<c04cb31f>] ? sys_sendmsg+0x12f/0x230
[ 3504.615354]  [<c010974f>] ? native_sched_clock+0x7f/0xb0
[ 3504.615354]  [<c036db16>] ? copy_from_user+0x46/0x80
[ 3504.615354]  [<c04cb4c5>] ? sys_sendto+0xa5/0xd0
[ 3504.615354]  [<c04cd20f>] ? release_sock+0xbf/0xd0
[ 3504.615354]  [<c05fe50f>] ? _spin_unlock_bh+0x2f/0x40
[ 3504.615354]  [<c04cc6ee>] ? sock_ioctl+0x6e/0x1b0
[ 3504.615354]  [<c04cc37d>] ? sys_socketcall+0x13d/0x260
[ 3504.615354]  [<c0103d7d>] ? sysenter_past_esp+0x6a/0xb1
[ 3504.615354]  =======================
[ 3504.615354] Code: 00 00 89 5c 24 14 8b 98 90 00 00 00 89 54 24 0c 89
5c 24 10 8b 40 50 89 4c 24 04 c7 04 24 f0 f8 76 c0 89 44 24 08 e8 94 63
c5 ff <0f> 0b eb fe 55 89 e5 56 53 bb 73 84 73 c0 83 ec 24 8b 70 14 85 
[ 3504.615354] EIP: [<c04cff7c>] skb_under_panic+0x5c/0x60 SS:ESP
0068:c91d4c04
[ 3504.695974] ---[ end trace 93117dac2000f4c6 ]---

