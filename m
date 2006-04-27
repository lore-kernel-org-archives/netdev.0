From: "Ed L. Cashin" <ecashin@coraid.com>
Subject: 2.6.16.11 BUG at tg3.c:2917
Date: Thu, 27 Apr 2006 12:52:34 -0400
Message-ID: <20060427165234.GC29045@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.coraid.com ([65.14.39.133]:62805 "EHLO coraid.com")
	by vger.kernel.org with ESMTP id S965158AbWD0RKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 13:10:42 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.  On 2.6.15.7 and 2.6.16.11, I have seen panics under heavy NFS
write load on an x86_64 system with two onboard Broadcom gigabit NICs.
It's a Supermicro P8SCi motherboard with an EMT64 Intel CPU.  The aoe
driver in use is the aoe6-26 driver from the Coraid website.

I haven't yet trimmed down the test case or tried using the aoe driver
that comes with 2.6.16.11.  Right now there's kernel NFS exporting an
XFS filesystem on a logical volume backed by 3 AoE devices.

I'm including two panics here.

There's a relevant-looking discussion of the same bug from May 2005 at
the URL below.

  http://oss.sgi.com/projects/netdev/archive/2004-05/msg00378.html


----------- [cut here ] --------- [please bite here ] ---------
Kernel BUG at drivers/net/tg3.c:2917
invalid opcode: 0000 [1] SMP 
CPU 0 
Modules linked in: nfsd lockd nfs_acl sunrpc xfs exportfs dm_mod aoe ipv6 rtc piix i2c_i801 psmouse evdev i2c_core unix
Pid: 3053, comm: nfsd Not tainted 2.6.16.11-c1 #1
RIP: 0010:[<ffffffff802302ac>] <ffffffff802302ac>{tg3_poll+179}
RSP: 0000:ffffffff8039cc38  EFLAGS: 00010246
RAX: 00000000000001fb RBX: 0000000000000000 RCX: 0000000000000003
RDX: 0000000000000038 RSI: ffff81003f03f180 RDI: ffff810001fbb980
RBP: ffff81003d82df88 R08: 0000000000000400 R09: ffff81003e5fae18
R10: ffff81003ee86a80 R11: 00000000000000c4 R12: ffff81003f0d0500
R13: 00000000000001fb R14: 0000000000000016 R15: ffff810023088c30
FS:  00002b4cde2ee6d0(0000) GS:ffffffff803e6000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000438010 CR3: 0000000025729000 CR4: 00000000000006e0
Process nfsd (pid: 3053, threadinfo ffff81003d6fc000, task ffff81003f304140)
Stack: 0000000000000046 ffffffff802427b4 ffffffff8039ccd4 ffff81003f0d0000 
       ffff81003dfec000 000000140000002c 00000000000000ca 00ca8100000000ca 
       ffff81003dfdd920 ffff81003f0d059c 
Call Trace: <IRQ> <ffffffff802427b4>{task_in_intr+240}
       <ffffffff802720b5>{net_rx_action+165} <ffffffff8012e449>{__do_softirq+86}
       <ffffffff8010ba52>{call_softirq+30} <EOI> <ffffffff8010d13f>{do_softirq+44}
       <ffffffff8012e16c>{local_bh_enable+105} <ffffffff80273172>{dev_queue_xmit+551}
       <ffffffff88074579>{:aoe:aoenet_xmit+26} <ffffffff880723af>{:aoe:aoeblk_make_request+413}
       <ffffffff801b207a>{generic_make_request+335} <ffffffff8807bca2>{:dm_mod:__map_bio+66}
       <ffffffff8807befc>{:dm_mod:__split_bio+365} <ffffffff880e0f96>{:xfs:linvfs_get_block+0}
       <ffffffff8807c30a>{:dm_mod:dm_request+262} <ffffffff801b207a>{generic_make_request+335}
       <ffffffff801b24e7>{submit_bio+184} <ffffffff880e39cd>{:xfs:xfs_buf_iorequest+828}
       <ffffffff80124b9d>{default_wake_function+0} <ffffffff880e3240>{:xfs:xfs_buf_associate_memory+117}
       <ffffffff880cc103>{:xfs:xlog_bdstrat_cb+22} <ffffffff880cc794>{:xfs:xlog_state_release_iclog+695}
       <ffffffff880ce890>{:xfs:xlog_write+1509} <ffffffff880ce95c>{:xfs:xfs_log_write+42}
       <ffffffff880d66f4>{:xfs:_xfs_trans_commit+1294} <ffffffff880e0790>{:xfs:kmem_zone_alloc+73}
       <ffffffff880e07f9>{:xfs:kmem_zone_zalloc+28} <ffffffff880c5957>{:xfs:xfs_itruncate_finish+530}
       <ffffffff880daeb3>{:xfs:xfs_inactive_free_eofblocks+384}
       <ffffffff880e40e3>{:xfs:linvfs_release+0} <ffffffff880daf90>{:xfs:xfs_release+152}
       <ffffffff880e40fa>{:xfs:linvfs_release+23} <ffffffff80164fe2>{__fput+155}
       <ffffffff88144d64>{:nfsd:nfsd_write+196} <ffffffff8814bc1c>{:nfsd:nfsd3_proc_write+231}
       <ffffffff881413c2>{:nfsd:nfsd_dispatch+221} <ffffffff8810c360>{:sunrpc:svc_process+975}
       <ffffffff802c672f>{__down_read+18} <ffffffff88141648>{:nfsd:nfsd+451}
       <ffffffff8010b702>{child_rip+8} <ffffffff88141485>{:nfsd:nfsd+0}
       <ffffffff8010b6fa>{child_rip+0}

Code: 0f 0b 68 83 5f 2f 80 c2 65 0b 49 8b 44 24 40 8b 93 88 00 00 
RIP <ffffffff802302ac>{tg3_poll+179} RSP <ffffffff8039cc38>
 <0>Kernel panic - not syncing: Aiee, killing interrupt handler!
 

----------- [cut here ] --------- [please bite here ] ---------
Kernel BUG at drivers/net/tg3.c:2914
invalid operand: 0000 [1] SMP
CPU 0
Modules linked in: nfsd lockd nfs_acl sunrpc dm_mod aoe xfs exportfs ipv6 i2c_i801 i2c_core piix md_mod rtc psmouse unix
Pid: 88, comm: kswapd0 Not tainted 2.6.15.7-c1 #1
RIP: 0010:[<ffffffff802329ee>] <ffffffff802329ee>{tg3_poll+179}
RSP: 0000:ffffffff80395e08  EFLAGS: 00010246
RAX: 0000000000000066 RBX: 0000000000000000 RCX: 0000000000000002
RDX: 0000000000000028 RSI: ffff81003e999d80 RDI: ffff810001fbba40
RBP: ffff81003dd63990 R08: ffffffff80395ea8 R09: ffff81003dc2ce18
R10: 000000000000003a R11: ffffffff80395ea8 R12: ffff81003f1a3500
R13: 0000000000000066 R14: 00000000000000a9 R15: ffffffff80395f08
FS:  0000000000000000(0000) GS:ffffffff803e1800(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000000004a12a7 CR3: 00000000077ab000 CR4: 00000000000006e0
Process kswapd0 (pid: 88, threadinfo ffff81003f5d8000, task ffff81003f594790)
Stack: ffffffff803c8980 0000000000001d4c ffffffff80395ea4 ffff81003f1a3000
       ffff81003db45000 0000004000000000 0000000000000049 004900000000003b
       ffff81003e52c740 ffff81003f1a359c
Call Trace: <IRQ> <ffffffff80273e14>{net_rx_action+165} <ffffffff8013348c>{__do_softirq+86}
       <ffffffff8010eaef>{call_softirq+31} <ffffffff80110187>{do_softirq+44}
       <ffffffff801101bf>{do_IRQ+52} <ffffffff8010dd10>{ret_from_intr+0}
        <EOI> <ffffffff80154a80>{cache_flusharray+30} <ffffffff880d776c>{:xfs:linvfs_release_page+0}
       <ffffffff802c81d7>{_write_unlock_irqrestore+9} <ffffffff80152a41>{test_clear_page_dirty+152}
       <ffffffff8016ad64>{try_to_free_buffers+116} <ffffffff880d776c>{:xfs:linvfs_release_page+0}
       <ffffffff880d77f1>{:xfs:linvfs_release_page+133} <ffffffff801577d0>{shrink_zone+2695}
       <ffffffff80129aa5>{activate_task+140} <ffffffff8012a713>{try_to_wake_up+1110}
       <ffffffff80157d53>{balance_pgdat+535} <ffffffff80157fb2>{kswapd+256}
       <ffffffff80141334>{autoremove_wake_function+0} <ffffffff8010e65e>{child_rip+8}
       <ffffffff80157eb2>{kswapd+0} <ffffffff8010e656>{child_rip+0}


Code: 0f 0b 68 ba 2d 2f 80 c2 62 0b 49 8b 44 24 40 8b 93 80 00 00
RIP <ffffffff802329ee>{tg3_poll+179} RSP <ffffffff80395e08>
 <0>Kernel panic - not syncing: Aiee, killing interrupt handler!


-- 
  Ed L Cashin <ecashin@coraid.com>
