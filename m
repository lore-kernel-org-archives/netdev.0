From: belyshev@depni.sinp.msu.ru
Subject: Kernel BUG at "net/ipv4/tcp_output.c":928
Date: Wed, 08 Jun 2005 20:16:40 +0400
Message-ID: <561x7c963b.fsf@depni.sinp.msu.ru>
References: <56hdg93rxb.fsf@depni.sinp.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <56hdg93rxb.fsf@depni.sinp.msu.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>Seems that this oops happens only if using hostap.

Apparently this has nothing to do with hostap, as I was able to reproduce this
without it:

----------- [cut here ] --------- [please bite here ] ---------
Kernel BUG at "net/ipv4/tcp_output.c":928
invalid operand: 0000 [1] 
CPU 0 
Modules linked in:
Pid: 2854, comm: nc Not tainted 2.6.12-rc6-mm1-gcc34
RIP: 0010:[<ffffffff803dad47>] <ffffffff803dad47>{tcp_tso_should_defer+55}
RSP: 0018:ffff810018b29c08  EFLAGS: 00010246
RAX: 000000000000002c RBX: ffff81001e0cdd40 RCX: 0000000005a80100
RDX: ffff81001e0cdd40 RSI: ffff81001ed44040 RDI: 0000000000000002
RBP: ffff81001ed44040 R08: 0000000000000000 R09: ffff810018b29d60
R10: 0000000000000002 R11: ffffffff8018c200 R12: ffff81001ed44040
R13: ffff81001ed44040 R14: 000000000000002d R15: 00000000000005a8
FS:  00002aaaaae00c80(0000) GS:ffffffff8081c840(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000007bd0d8 CR3: 0000000018b7d000 CR4: 00000000000006e0
Process nc (pid: 2854, threadinfo ffff810018b28000, task ffff81001f704f70)
Stack: ffff81001e0cdd40 ffffffff803daea4 ffff81001ed440d8 0000000000000296 
       0000000100000001 ffff81001ed44040 ffff81001ed44040 0000000000000000 
       0000000000000000 ffff81001a824088 
Call Trace:<ffffffff803daea4>{tcp_write_xmit+212} <ffffffff803db1b9>{__tcp_push_pending_frames+41}
       <ffffffff803d2153>{tcp_close+595} <ffffffff803ed8b8>{inet_release+88}
       <ffffffff8038ac01>{sock_release+33} <ffffffff8038b8e5>{sock_close+53}
       <ffffffff80173972>{__fput+194} <ffffffff8017222e>{filp_close+110}
       <ffffffff801334f3>{put_files_struct+115} <ffffffff80133da4>{do_exit+484}
       <ffffffff8013b745>{__dequeue_signal+501} <ffffffff8013477f>{do_group_exit+159}
       <ffffffff8013d267>{get_signal_to_deliver+1239} <ffffffff8010dd52>{do_signal+162}
       <ffffffff8017e3a7>{pipe_readv+823} <ffffffff80486968>{cond_resched+56}
       <ffffffff801978a1>{inotify_inode_queue_event+49} <ffffffff80145b00>{autoremove_wake_function+0}
       <ffffffff80172bcd>{vfs_write+317} <ffffffff8010e95b>{sysret_signal+28}
       <ffffffff8010ec43>{ptregscall_common+103} 

Code: 0f 0b 56 a9 4e 80 ff ff ff ff a0 03 44 8b 86 14 03 00 00 44 
RIP <ffffffff803dad47>{tcp_tso_should_defer+55} RSP <ffff810018b29c08>
 <1>Fixing recursive fault but reboot is needed!
