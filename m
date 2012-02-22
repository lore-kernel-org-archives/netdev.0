From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Wed, 22 Feb 2012 09:19:57 -0800
Message-ID: <20120222091957.7f90aa8a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48093 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751334Ab2BVRUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 12:20:04 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 706FF142000F
	for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 09:20:03 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nJp+p3WbTYHY for <netdev@vger.kernel.org>;
	Wed, 22 Feb 2012 09:19:58 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 54DC61410009
	for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 09:19:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 22 Feb 2012 10:24:19 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 42809] New: kernel panic when receiving an ipsec packet


https://bugzilla.kernel.org/show_bug.cgi?id=42809

           Summary: kernel panic when receiving an ipsec packet
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.32.54
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: darkbasic@linuxsystems.it
        Regression: No


As soon as I receive an ipsec packet (NETKEY of course) I get a kernel panic.
Even magicsysrq keys do not work anymore.

O.S. Debian Squeeze amd64. I tried both Strongswan and Openswan.

[  135.642460] BUG: unable to handle kernel paging request at 
ffff8802aef2fbff
[  135.649876] IP: [<ffffffff81196213>] memmove+0xf/0x3c
[  135.655282] PGD 1002063 PUD 0
[  135.658629] Thread overran stack, or stack corrupted
[  135.663781] Oops: 0000 [#1] SMP
[  135.667275] last sysfs file: /sys/module/zlib_deflate/initstate
[  135.673380] CPU 0
[  135.675606] Modules linked in: authenc deflate ctr camellia cast5 
rmd160 sha1_generic hmac crypto_null ccm serpent blowfish twofish 
twofish_common ecb xcbc cbc sha256_generic s]
[  135.813814] Pid: 0, comm: swapper Not tainted 2.6.32-5-amd64 #1 To Be 
Filled By O.E.M.
[  135.822044] RIP: 0010:[<ffffffff81196213>]  [<ffffffff81196213>] 
memmove+0xf/0x3c
[  135.829956] RSP: 0018:ffff880007203ca0  EFLAGS: 00010293
[  135.835539] RAX: ffff8801aef2fc00 RBX: ffff8801b035d700 RCX: 
0000000000000009
[  135.842994] RDX: 0000000000000009 RSI: ffff8802aef2fbff RDI: 
ffff8801aef2fc33
[  135.850384] RBP: ffff8801b035d738 R08: 0000000000000000 R09: 
ffff8801aef2fc33
[  135.857791] R10: ffff8801aec8f178 R11: ffffffffa048e0ef R12: 
ffff8801aec8f800
[  135.865149] R13: 0000000000000002 R14: 0000000000000004 R15: 
0000000000000000
[  135.872575] FS:  0000000000000000(0000) GS:ffff880007200000(0000) 
knlGS:0000000000000000
[  135.885892] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[  135.891902] CR2: ffff8802aef2fbff CR3: 00000001aa4fb000 CR4: 
00000000000006f0
[  135.899362] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[  135.906857] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[  135.914239] Process swapper (pid: 0, threadinfo ffffffff8142e000, 
task ffffffff814891f0)
[  135.922570] Stack:
[  135.924726]  ffff8801b035d700 ffffffffa048e254 ffff8801aec8f800 
ffff8801b035d700
[  135.932479] <0> 0000000000000004 ffffffff812b0ab6 9411941100000011 
ffffffff816d35b0
[  135.940803] <0> e940ab4d00000000 ea5d2cd94b9e8da7 01000000a6e1ad80 
ffff8801aaf71040
[  135.949461] Call Trace:
[  135.952060]  <IRQ>
[  135.954349]  [<ffffffffa048e254>] ? 
xfrm4_mode_tunnel_input+0x165/0x189 [xfrm4_mode_tunnel]
[  135.963057]  [<ffffffff812b0ab6>] ? xfrm_input+0x26f/0x386
[  135.968743]  [<ffffffff8129340c>] ? udp_queue_rcv_skb+0x56/0x201
[  135.974993]  [<ffffffff81293993>] ? __udp4_lib_rcv+0x3dc/0x5e7
[  135.981097]  [<ffffffff81273896>] ? ip_local_deliver_finish+0x0/0x1e9
[  135.987814]  [<ffffffff812739dc>] ? ip_local_deliver_finish+0x146/0x1e9
[  135.994684]  [<ffffffff8127352b>] ? ip_rcv_finish+0x373/0x38d
[  136.000639]  [<ffffffff812737e5>] ? ip_rcv+0x2a0/0x2ed
[  136.006026]  [<ffffffff8124fb55>] ? process_backlog+0x81/0xb4
[  136.011963]  [<ffffffff8125013b>] ? net_rx_action+0xae/0x1c9
[  136.017817]  [<ffffffff81053dc7>] ? __do_softirq+0xdd/0x1a6
[  136.023590]  [<ffffffff81011cac>] ? call_softirq+0x1c/0x30
[  136.029322]  [<ffffffff8101322b>] ? do_softirq+0x3f/0x7c
[  136.034844]  [<ffffffff81053c37>] ? irq_exit+0x36/0x76
[  136.040185]  [<ffffffff81012922>] ? do_IRQ+0xa0/0xb6
[  136.045347]  [<ffffffff810114d3>] ? ret_from_intr+0x0/0x11
[  136.051026]  <EOI>
[  136.053318]  [<ffffffff810176a4>] ? mwait_idle+0x72/0x7d
[  136.058857]  [<ffffffff81017654>] ? mwait_idle+0x22/0x7d
[  136.064349]  [<ffffffff8100fe97>] ? cpu_idle+0xa2/0xda
[  136.069708]  [<ffffffff8151c140>] ? early_idt_handler+0x0/0x71
[  136.075743]  [<ffffffff8151ccdd>] ? start_kernel+0x3dc/0x3e8
[  136.081559]  [<ffffffff8151c3b7>] ? x86_64_start_kernel+0xf9/0x106
[  136.087974] Code: 17 0f 1f 80 00 00 00 00 44 8a 06 44 88 07 48 ff c7 
48 ff c6 ff c9 75 f0 c3 90 90 90 48 83 ec 08 48 39 f7 49 89 f9 48 89 d1 
73 04 <f3> a4 eb 1d 4c 8d 04 17 48
[  136.111424] RIP  [<ffffffff81196213>] memmove+0xf/0x3c
[  136.116814]  RSP <ffff880007203ca0>
[  136.120428] CR2: ffff8802aef2fbff
[  136.123877] ---[ end trace a549686a4982f42d ]---
[  136.128728] Kernel panic - not syncing: Fatal exception in interrupt
[  136.135363] Pid: 0, comm: swapper Tainted: G      D    2.6.32-5-amd64 #1
[  136.142339] Call Trace:
[  136.144925]  <IRQ>  [<ffffffff812fade7>] ? panic+0x86/0x143
[  136.150823]  [<ffffffff81068740>] ? up+0xe/0x37
[  136.155536]  [<ffffffff8104e5af>] ? release_console_sem+0x17e/0x1af
[  136.162093]  [<ffffffff812fdb25>] ? oops_end+0xa7/0xb4
[  136.167503]  [<ffffffff810323f0>] ? no_context+0x1e9/0x1f8
[  136.173206]  [<ffffffff810325a5>] ? __bad_area_nosemaphore+0x1a6/0x1ca
[  136.179918]  [<ffffffffa054c4cf>] ? crypto_cbc_decrypt+0x101/0x11f [cbc]
[  136.186895]  [<ffffffff812feeef>] ? do_page_fault+0x69/0x2fc
[  136.192794]  [<ffffffff812fd005>] ? page_fault+0x25/0x30
[  136.198336]  [<ffffffffa048e0ef>] ? xfrm4_mode_tunnel_input+0x0/0x189 
[xfrm4_mode_tunnel]
[  136.206791]  [<ffffffff81196213>] ? memmove+0xf/0x3c
[  136.212019]  [<ffffffffa048e254>] ? 
xfrm4_mode_tunnel_input+0x165/0x189 [xfrm4_mode_tunnel]
[  136.220718]  [<ffffffff812b0ab6>] ? xfrm_input+0x26f/0x386
[  136.226414]  [<ffffffff8129340c>] ? udp_queue_rcv_skb+0x56/0x201
[  136.232620]  [<ffffffff81293993>] ? __udp4_lib_rcv+0x3dc/0x5e7
[  136.238645]  [<ffffffff81273896>] ? ip_local_deliver_finish+0x0/0x1e9
[  136.245322]  [<ffffffff812739dc>] ? ip_local_deliver_finish+0x146/0x1e9
[  136.252184]  [<ffffffff8127352b>] ? ip_rcv_finish+0x373/0x38d
[  136.258157]  [<ffffffff812737e5>] ? ip_rcv+0x2a0/0x2ed
[  136.263565]  [<ffffffff8124fb55>] ? process_backlog+0x81/0xb4
[  136.269523]  [<ffffffff8125013b>] ? net_rx_action+0xae/0x1c9
[  136.275384]  [<ffffffff81053dc7>] ? __do_softirq+0xdd/0x1a6
[  136.281236]  [<ffffffff81011cac>] ? call_softirq+0x1c/0x30
[  136.286951]  [<ffffffff8101322b>] ? do_softirq+0x3f/0x7c
[  136.292446]  [<ffffffff81053c37>] ? irq_exit+0x36/0x76
[  136.297781]  [<ffffffff81012922>] ? do_IRQ+0xa0/0xb6
[  136.303009]  [<ffffffff810114d3>] ? ret_from_intr+0x0/0x11
[  136.308750]  <EOI>  [<ffffffff810176a4>] ? mwait_idle+0x72/0x7d
[  136.314939]  [<ffffffff81017654>] ? mwait_idle+0x22/0x7d
[  136.320422]  [<ffffffff8100fe97>] ? cpu_idle+0xa2/0xda
[  136.325807]  [<ffffffff8151c140>] ? early_idt_handler+0x0/0x71
[  136.331841]  [<ffffffff8151ccdd>] ? start_kernel+0x3dc/0x3e8
[  136.337763]  [<ffffffff8151c3b7>] ? x86_64_start_kernel+0xf9/0x106

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
