From: Dave Jones <davej@redhat.com>
Subject: 2.6.4 sunrpc oops.
Date: Mon, 15 Mar 2004 19:46:42 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315194642.GB19555@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

To repeat..

modprobe auth_rpcgss
rmmod auth_rpcgss
rmmod sunrpc
*bang*

Seems to survive rmmod sunrpc usually, so it's the auth_rpcgcc
module leaving something around long after its dead perhaps?

		Dave

Unable to handle kernel paging request at virtual address c7890674
 printing eip:
c78ffabf
*pde = 06f3f067
*pte = 00000000
Oops: 0000 [#1]
SMP
CPU:    0
EIP:    0060:[<c78ffabf>]    Not tainted
EFLAGS: 00010283   (2.6.4-prep)
EIP is at cache_clean+0xbb/0x298 [sunrpc]
eax: 4056078d   ebx: c7912020   ecx: c789066c   edx: c7890640
esi: c031bbd8   edi: 00000000   ebp: c33e5000   esp: c33e5f40
ds: 007b   es: 007b   ss: 0068
Process rmmod (pid: 1682, threadinfo=c33e5000 task=c5ade670)
Stack: c7912020 c7912020 c7912020 c031bbd8 00000000 c78ffcf4 c78ff7a9 000000cc
       000000cc c7912880 c7902e09 c01376cc 00000000 726e7573 c3006370 c3d7a5ac
       b8005000 c014f9e1 c359cc98 b8006000 c014fe8f c3d7a5e8 c35f2104 c6c673e4
Call Trace:
 [<c78ffcf4>] cache_flush+0x1a/0x3b [sunrpc]
 [<c78ff7a9>] cache_unregister+0xa/0x179 [sunrpc]
 [<c7902e09>] cleanup_sunrpc+0x14/0x5e [sunrpc]
 [<c01376cc>] sys_delete_module+0x115/0x157
 [<c014f9e1>] unmap_vma_list+0xe/0x17
 [<c014fe8f>] do_munmap+0x17e/0x18a
 [<c02c4567>] syscall_call+0x7/0xb
 
Code: 39 42 34 76 0a 8b 41 d4 a3 84 33 91 c7 eb 12 c7 05 84 33 91
