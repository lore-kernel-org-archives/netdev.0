From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: Panic in sk_stream_wait_memory() while doing iSCSI testing
Date: 28 Apr 2005 15:22:54 -0700
Message-ID: <1114726972.26913.711.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I ran into panic in sk_stream_wait_memory() while doing iSCSI
testing on 2.6.12-rc2. The problem seems to be while doing

        set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);

sk->sk_socket seems to be NULL. Can this happen ? Do we need
to check for sk_error or sk_shutdown before de-ref sk->sk_socket ?

Is this a known and/or fixed problem ? Please let me know.


Thanks,
Badari


Unable to handle kernel NULL pointer dereference at 0000000000000008
RIP:
<ffffffff803852d7>{sk_stream_wait_memory+199}
Oops: 0002 [1] SMP
CPU 0
Modules linked in: joydev sg st floppy usbserial parport_pc lp parport
ipv6 ohcvPid: 26987, comm: kjournald Not tainted 2.6.12-rc2n  0:06.47
pdflush
RIP: 0010:[<ffffffff803852d7>]
<ffffffff803852d7>{sk_stream_wait_memory+199}
RSP: 0018:ffff810154261978  EFLAGS: 000102469  0.0   0:06.40 dd
RAX: 0000000000000000 RBX: ffff81017f3eac00 RCX: 0000000000000296
RDX: ffff81000c005ba8 RSI: 0000000000000296 RDI: ffff81017f3eac38
RBP: 0000000000003a8d R08: 0000000000000000 R09: 000000000000000c
R10: 00000000ffffffff R11: 0000000000000000 R12: 0000000000000000
R13: ffff810154261a68 R14: ffff8101542619a8 R15: 0000000000000000
FS:  00002aaaaade3700(0000) GS:ffffffff806533c0(0000)
knlGS:0000000055975080
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b0   0:05.89 dd
CR2: 0000000000000008 CR3: 00000001ba0e3000 CR4: 00000000000006e0
Process kjournald (pid: 26987, threadinfo ffff810154260000, task
ffff8101d9a595)Stack: 0000000000000000 ffff8101d9a59520 ffffffff8014c6e0
ffff8101542619c0
       ffff8101542619c0 ffff8101d62d7900 0000000000000000
ffff8101d9a59520
       ffffffff8014c6e0 ffff8101542619c0
Call Trace:<ffffffff8014c6e0>{autoremove_wake_function+0}
       <ffffffff803af654>{tcp_sendpage+2260}
       <ffffffff801609c4>{mempool_alloc+164}
       <ffffffff8031f316>{scsi_dispatch_cmd+566}
       <ffffffff802e098d>{__generic_unplug_device+45}
       <ffffffff802df9b2>{generic_make_request+546}
       <ffffffff8014c6e0>{autoremove_wake_function+0}
       <ffffffff802dfaaf>{submit_bio+223}
       <ffffffff801823db>{submit_bh+283}
<ffffffff80183939>{ll_rw_block+105}
       <ffffffff80201a83>{journal_commit_transaction+1523}
       <ffffffff80403601>{thread_return+0}
<ffffffff8040365a>{thread_return+89}
       <ffffffff80131353>{__wake_up+67}
<ffffffff8020780a>{kjournald+394}
       <ffffffff8014c6e0>{autoremove_wake_function+0}
<ffffffff8014c6e0>{autore
       <ffffffff80207a90>{commit_timeout+0}
<ffffffff8010f77b>{child_rip+8}
       <ffffffff80207680>{kjournald+0} <ffffffff8010f773>{child_rip+0}
                                                                            
                                                                             
Code: f0 0f ba 68 08 00 48 8b 7b 60 ba 01 00 00 00 4c 89 f6 e8 62
RIP <ffffffff803852d7>{sk_stream_wait_memory+199} RSP <ffff810154261978>
CR2: 0000000000000008
