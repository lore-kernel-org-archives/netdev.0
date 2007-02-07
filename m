From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: [Bugme-new] [Bug 7962] New: oops in port_carrier_check
Date: Wed, 7 Feb 2007 12:52:16 -0800
Message-ID: <20070207125216.7a81360c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, pterjan@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36209 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161424AbXBGUw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 15:52:28 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 7 Feb 2007 12:41:07 -0800
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7962] New: oops in port_carrier_check


http://bugzilla.kernel.org/show_bug.cgi?id=7962

           Summary: oops in port_carrier_check
    Kernel Version: 2.6.20-rc7
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: pterjan@gmail.com


While playing with qemu, I got a oops in bridge (and lost keyboard) :

Feb  7 21:20:18 plop kernel: BUG: unable to handle kernel paging request at
virtual address 6b6b6b6b
Feb  7 21:20:18 plop kernel:  printing eip:
Feb  7 21:20:18 plop kernel: *pde = 00000000
Feb  7 21:20:18 plop kernel: Oops: 0000 [#1]
Feb  7 21:20:18 plop kernel: CPU:    0
Feb  7 21:20:19 plop kernel: EIP:    0060:[pg0+814360305/1067136000]    Not
tainted VLI
Feb  7 21:20:19 plop kernel: EIP:    0060:[<f0eed6f1>]    Not tainted VLI
Feb  7 21:20:19 plop kernel: EFLAGS: 00010202   (2.6.20.0.rc7-1mdv #1)
Feb  7 21:20:19 plop kernel: EIP is at port_carrier_check+0x22/0x75 [bridge]
Feb  7 21:20:19 plop kernel: eax: 6b6b6b6b   ebx: 6b6b6b6b   ecx: 00000000  
edx: 00000001
Feb  7 21:20:19 plop kernel: esi: eb99b120   edi: 00000296   ebp: eff0bf58  
esp: eff0bf4c
Feb  7 21:20:19 plop kernel: ds: 007b   es: 007b   ss: 0068
Feb  7 21:20:19 plop kernel: Process events/0 (pid: 4, ti=eff0a000 task=eff09530
task.ti=eff0a000)
Feb  7 21:20:19 plop kernel: Stack: cd566744 eff4e86c 00000296 eff0bf84 c012534a
eff0bf70 00000296 eff0bfa0
Feb  7 21:20:19 plop kernel:        eff0bfac cd566740 f0eed6cf eff4e86c eff03ec8
eff0bfb4 eff0bfc4 c012590d
Feb  7 21:20:19 plop kernel:        00000001 00000000 00000001 00010000 00000000
00000000 eff09530 c0114770
Feb  7 21:20:19 plop kernel: Call Trace:
Feb  7 21:20:19 plop kernel:  [show_trace_log_lvl+26/47]
show_trace_log_lvl+0x1a/0x2f
Feb  7 21:20:19 plop kernel:  [<c010422c>] show_trace_log_lvl+0x1a/0x2f
Feb  7 21:20:19 plop kernel:  [show_stack_log_lvl+155/163]
show_stack_log_lvl+0x9b/0xa3
Feb  7 21:20:19 plop kernel:  [<c01042dc>] show_stack_log_lvl+0x9b/0xa3
Feb  7 21:20:19 plop kernel:  [show_registers+402/616] show_registers+0x192/0x268
Feb  7 21:20:19 plop kernel:  [<c0104476>] show_registers+0x192/0x268
Feb  7 21:20:19 plop kernel:  [die+234/511] die+0xea/0x1ff
Feb  7 21:20:19 plop kernel:  [<c0104636>] die+0xea/0x1ff
Feb  7 21:20:19 plop kernel:  [do_page_fault+1111/1334] do_page_fault+0x457/0x536
Feb  7 21:20:19 plop kernel:  [<c02c0c73>] do_page_fault+0x457/0x536
Feb  7 21:20:19 plop kernel:  [error_code+116/128] error_code+0x74/0x80
Feb  7 21:20:19 plop kernel:  [<c02bf624>] error_code+0x74/0x80
Feb  7 21:20:19 plop kernel:  [run_workqueue+142/333] run_workqueue+0x8e/0x14d
Feb  7 21:20:19 plop kernel:  [<c012534a>] run_workqueue+0x8e/0x14d
Feb  7 21:20:19 plop kernel:  [worker_thread+260/302] worker_thread+0x104/0x12e 
Feb  7 21:20:19 plop kernel:  [<c012590d>] worker_thread+0x104/0x12e
Feb  7 21:20:19 plop kernel:  [kthread+163/206] kthread+0xa3/0xce
Feb  7 21:20:19 plop kernel:  [<c0127e55>] kthread+0xa3/0xce
Feb  7 21:20:19 plop kernel:  [kernel_thread_helper+7/16]
kernel_thread_helper+0x7/0x10
Feb  7 21:20:19 plop kernel:  [<c0103ed7>] kernel_thread_helper+0x7/0x10
Feb  7 21:20:19 plop kernel:  ======================= 
Feb  7 21:20:19 plop kernel: Code: 38 cf 89 d8 5b 5e 5f 5d c3 55 89 e5 57 56 53
8b b0 24 ff ff ff 0f ba 30 00 e8 d3 20 38 cf 8b 9e 40 02 00 00 85 db 74 4c 8b 46
2c <8b> 3b a8 10 75 0a 89 f0 e8 e2 f9 ff ff 89 43 2c 8b 47 30 f6 40 
Feb  7 21:20:19 plop kernel: EIP: [pg0+814360305/1067136000]
port_carrier_check+0x22/0x75 [bridge] SS:ESP 0068:eff0bf4c
Feb  7 21:20:19 plop kernel: EIP: [<f0eed6f1>] port_carrier_check+0x22/0x75
[bridge] SS:ESP 0068:eff0bf4c

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
