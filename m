From: belyshev@depni.sinp.msu.ru
Subject: oops with hostap and 2.6.12-rc6-mm1: Kernel BUG at
 "net/ipv4/tcp_output.c":928
Date: Wed, 08 Jun 2005 17:21:36 +0400
Message-ID: <56hdg93rxb.fsf@depni.sinp.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Seems that this oops happens only if using hostap.

$ cat /dev/zero | nc host.com discard
^C
Segmentation fault

----------- [cut here ] --------- [please bite here ] ---------
Kernel BUG at "net/ipv4/tcp_output.c":928
invalid operand: 0000 [1] 
CPU 0 
Modules linked in: hostap_cs hostap
Pid: 3312, comm: nc Not tainted 2.6.12-rc6-mm1
RIP: 0010:[<ffffffff803ea297>] <ffffffff803ea297>{tcp_tso_should_defer+55}
RSP: 0018:ffff810015769c10  EFLAGS: 00010246
RAX: 0000000000000017 RBX: ffff81001e751340 RCX: 0000000005a80100
RDX: ffff81001e751340 RSI: ffff81001388aac0 RDI: 0000000000000002
RBP: ffff81001388aac0 R08: 0000000000000000 R09: ffff810015769d58
R10: 0000000000000000 R11: 0000000000000002 R12: 0000000000000000
R13: 0000000000000000 R14: ffff81001388aac0 R15: 0000000000000018
FS:  00002aaaaae00c80(0000) GS:ffffffff8082e840(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000005c5008 CR3: 0000000013eb4000 CR4: 00000000000006e0
Process nc (pid: 3312, threadinfo ffff810015768000, task ffff81001ed2b750)
Stack: ffffffff803ecaa4 ffff8100016c7bd8 000005a800000001 0000000000000001 
       ffff81001388aac0 ffff81001388aac0 0000000000000000 0000000000000000 
       ffff810019e4e888 ffff81001559f828 
Call Trace:<ffffffff803ecaa4>{tcp_write_xmit+196} <ffffffff803ece79>{__tcp_push_pending_frames+41}
       <ffffffff803e1361>{tcp_close+593} <ffffffff803fd9ec>{inet_release+92}
       <ffffffff80398b41>{sock_release+33} <ffffffff803993c5>{sock_close+53}
       <ffffffff80175ee2>{__fput+194} <ffffffff801733d8>{filp_close+104}
       <ffffffff80133fd4>{put_files_struct+116} <ffffffff80134f1a>{do_exit+522}
       <ffffffff80135931>{do_group_exit+177} <ffffffff8013f657>{get_signal_to_deliver+1255}
       <ffffffff8010e0fd>{do_signal+157} <ffffffff80146f90>{autoremove_wake_function+0}
       <ffffffff8019ac79>{inotify_inode_queue_event+41} <ffffffff8017551f>{vfs_write+303}
       <ffffffff8010ea33>{sysret_signal+28} <ffffffff8010ed1b>{ptregscall_common+103}
       

Code: 0f 0b de b7 4f 80 ff ff ff ff a0 03 44 8b 8e 14 03 00 00 44 
RIP <ffffffff803ea297>{tcp_tso_should_defer+55} RSP <ffff810015769c10>
 <1>Fixing recursive fault but reboot is needed!
