From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: Fwd: non-fatal oops with EIP at skb_release_data, available for debugging
Date: Sat, 5 Mar 2005 00:39:31 +0100
Message-ID: <5a4c581d0503041539e1ab137@mail.gmail.com>
References: <5a4c581d05030412482a596ee5@mail.gmail.com>
Reply-To: Alessandro Suardi <alessandro.suardi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <5a4c581d05030412482a596ee5@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hmm, doesn't seem this ever made the lkml, no idea why...
 CC'ing netdev in case someone can spot anything interesting

The machine (running FC3) is still up and running after
 the oops.

---------- Forwarded message ----------
From: Alessandro Suardi <alessandro.suardi@gmail.com>
Date: Fri, 4 Mar 2005 21:48:18 +0100
Subject: non-fatal oops with EIP at skb_release_data, available for debugging
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


This is my K7-800, 256MB RAM machine running as
 ed2k/bittorrent 24/7 box... metacity died, but the
 windows are still alive (and working) so if someone
 wants to get more info about it, just ping me...

[root@donkey ~]# cat /proc/version
Linux version 2.6.11-rc3-bk8 (asuardi@donkey) (gcc version 3.4.2
20041017 (Red Hat 3.4.2-6.fc3)) #1 Sat Feb 12 00:01:28 CET 2005
[root@donkey ~]# lsmod
Module                  Size  Used by
loop                   15368  -
nls_iso8859_1           3840  -
parport_pc             29444  -
parport                24704  -
8139too                24896  -
floppy                 57392  -

>From the dmesg ring:

kernel BUG at include/linux/mm.h:343!
invalid operand: 0000 [#1]
PREEMPT
Modules linked in: loop nls_iso8859_1 parport_pc parport 8139too floppy
CPU:    0
EIP:    0060:[<c02da6a2>]    Not tainted VLI
EFLAGS: 00210256   (2.6.11-rc3-bk8)
EIP is at skb_release_data+0x92/0xa0
eax: 00000000   ebx: 00000000   ecx: cca36f80   edx: c11a97c0
esi: c4205f20   edi: c4205f20   ebp: cd149dcc   esp: cd149dc4
ds: 007b   es: 007b   ss: 0068
Process metacity (pid: 2109, threadinfo=cd148000 task=ce8935d0)
Stack: c4205f20 00000000 cd149dd8 c02da6bb c6e9a0c0 cd149df8 c02da737 c5134250
       00000000 c4205f20 c5134250 c4205f20 c5134250 cd149e4c c02feba6 00000000
       00000040 cc68c454 00000000 00000001 cc68c444 cd148000 00000001 00000000
Call Trace:
 [<c0102b2a>] show_stack+0x7a/0x90
 [<c0102cad>] show_registers+0x14d/0x1c0
 [<c0102ea4>] die+0xe4/0x180
 [<c01032e3>] do_invalid_op+0xa3/0xb0
 [<c01027a7>] error_code+0x2b/0x30
 [<c02da6bb>] kfree_skbmem+0xb/0x20
 [<c02da737>] __kfree_skb+0x67/0xf0
 [<c02feba6>] tcp_recvmsg+0x5f6/0x710
 [<c02da1e6>] sock_common_recvmsg+0x46/0x60
 [<c02d6bbe>] sock_aio_read+0xee/0x100
 [<c014e427>] do_sync_read+0x97/0xf0
 [<c014e511>] vfs_read+0x91/0x120
 [<c014e7ed>] sys_read+0x3d/0x70
 [<c01025a9>] sysenter_past_esp+0x52/0x75
Code: c9 e9 03 e5 e5 ff 8d 76 00 5b 5e c9 c3 89 d0 e8 c5 f2 e5 ff eb
cf 89 f0 e8 0c ff ff ff 5b 8b 86 98 00 00 00 5e c9 e9 de e4 e5 ff <0f>
0b 57 01 ab c5 35 c0 eb a5 8d 74 26 00 55 89 e5 53 89 c3 e8

Thanks,

 
--alessandro

  "There is no distance that I don't see
  I do have a will - No limit to my reach"
  
    (Wallflowers, "Empire In My Mind")
