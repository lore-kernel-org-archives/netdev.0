From: Tom Lendacky <toml@us.ibm.com>
Subject: Flow cache flush oops
Date: 18 Jun 2003 14:22:33 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1055964154.1818.59.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I consistently receive the following oops on 2.5.72 on an SMP machine
after flushing some IPSec policy's and sa's that I had established and
sent data through.  I have not been able to reproduce this on a UP
machine.  I haven't done a lot of debugging in an SMP environment so
if anyone else can reproduce this and help debug, it would be greatly
appreciated.  The oops data is below.

Thanks,
Tom

Unable to handle kernel NULL pointer dereference at virtual address 00000000
 printing eip:
c02bd20d
*pde = 00000000
Oops: 0000 [#1]
CPU:    1
EIP:    0060:[<c02bd20d>]    Not tainted
EFLAGS: 00010286
EIP is at flow_cache_flush_tasklet+0x3d/0xb0
eax: 00000000   ebx: 00000000   ecx: 0000000a   edx: 01408f80
esi: f7e7ff0c   edi: c04d2e80   ebp: 00000001   esp: f7e7fee8
ds: 007b   es: 007b   ss: 0068
Process events/1 (pid: 7, threadinfo=f7e7e000 task=f7f44ca0)
Stack: c0405920 f7e7ff0c f7e7ff14 00000293 c02bd391 f7e7ff0c f7e7ff0c 00000001
       00000000 00000000 00000001 00000001 00000001 f7e7ff1c f7e7ff1c f7532c60
       f7e7e000 f7035c00 f7e7ff4c f7f8c060 c0329a91 f7035c14 f7e7ff4c c0329b5b
Call Trace:
 [<c02bd391>] flow_cache_flush+0xa1/0xbf
 [<c0329a91>] xfrm_policy_gc_kill+0x71/0xa0
 [<c0329b5b>] xfrm_policy_gc_task+0x9b/0xb0
 [<c0134cf7>] worker_thread+0x237/0x330
 [<c0329ac0>] xfrm_policy_gc_task+0x0/0xb0
 [<c011fe30>] default_wake_function+0x0/0x30
 [<c010aff2>] ret_from_fork+0x6/0x14
 [<c011fe30>] default_wake_function+0x0/0x30
 [<c0134ac0>] worker_thread+0x0/0x330
 [<c0108ded>] kernel_thread_helper+0x5/0x18

Code: 8b 14 98 85 d2 74 36 8d b6 00 00 00 00 8d bf 00 00 00 00 8b
