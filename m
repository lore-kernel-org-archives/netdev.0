From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
	<avillaci@fiec.espol.edu.ec>
Subject: Memory corruption - can it be blamed on network code?
Date: Mon, 14 Feb 2011 11:53:30 -0500
Message-ID: <4D595E0A.2060101@fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000002050305070805020106"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.palosanto.com ([200.93.199.101]:53360 "EHLO
	pbx.palosanto.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751196Ab1BNR6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 12:58:46 -0500
Received: from srv64.palosanto.com (avillacis.palosanto.com [192.168.3.2])
	by pbx.palosanto.com (Postfix) with ESMTP id C044C3B308D4
	for <netdev@vger.kernel.org>; Mon, 14 Feb 2011 11:54:01 -0500 (ECT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000002050305070805020106
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I am experiencing a memory corruption since 2.6.35-rc6 that involves the intel i915 driver (but now might implicate network code as well). It is being tracked at https://bugs.freedesktop.org/show_bug.cgi?id=29325 and 
https://bugzilla.redhat.com/show_bug.cgi?id=665887, and might be the same bug as https://bugzilla.kernel.org/show_bug.cgi?id=25572 . Chris Wilson made a patch to allocate i915 memory on a separate slab, and asked me to run with that patch applied. With 
that, and with slub_debug=FZPU in the kernel command line, I get the attached reports. The first one seems to involve unix sockets, and appeared right after leaving the computer on through the weekend running Vuze the bittorrent client. The rest were 
invoked with slabinfo -v, and also seem to involve network data. Is this enough evidence to investigate the network subsystem? How should I proceed in investigation of this issue?

--------------000002050305070805020106
Content-Type: text/plain;
 name="redzone-corruption-2011-02-14.txt"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment;
 filename="redzone-corruption-2011-02-14.txt"

[256058.335325] =============================================================================
[256058.335330] BUG kmalloc-512: Poison overwritten
[256058.335332] -----------------------------------------------------------------------------
[256058.335333] 
[256058.335335] INFO: 0xffff88004c03e018-0xffff88004c03e01f. First byte 0x20 instead of 0x6b
[256058.335344] INFO: Allocated in alloc_skb+0x13/0x15 age=113119143 cpu=0 pid=0
[256058.335347] INFO: Freed in skb_release_data+0xb0/0xb5 age=113102249 cpu=1 pid=11022
[256058.335350] INFO: Slab 0xffffea00010a0d20 objects=28 used=6 fp=0xffff88004c03dff0 flags=0x200000000040c1
[256058.335352] INFO: Object 0xffff88004c03dff0 @offset=8176 fp=0xffff88004c03d6d0
[256058.335353] 
[256058.335355] Bytes b4 0xffff88004c03dfe0:  4f 9e 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a O.......ZZZZZZZZ
[256058.335366]   Object 0xffff88004c03dff0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335376]   Object 0xffff88004c03e000:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335387]   Object 0xffff88004c03e010:  6b 6b 6b 6b 6b 6b 6b 6b 20 40 8f 24 00 88 ff ff kkkkkkkk.@.$..��
[256058.335398]   Object 0xffff88004c03e020:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335409]   Object 0xffff88004c03e030:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335419]   Object 0xffff88004c03e040:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335430]   Object 0xffff88004c03e050:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335441]   Object 0xffff88004c03e060:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335452]   Object 0xffff88004c03e070:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335462]   Object 0xffff88004c03e080:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335473]   Object 0xffff88004c03e090:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335484]   Object 0xffff88004c03e0a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335495]   Object 0xffff88004c03e0b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335505]   Object 0xffff88004c03e0c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335516]   Object 0xffff88004c03e0d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335527]   Object 0xffff88004c03e0e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335537]   Object 0xffff88004c03e0f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335548]   Object 0xffff88004c03e100:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335559]   Object 0xffff88004c03e110:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335570]   Object 0xffff88004c03e120:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335580]   Object 0xffff88004c03e130:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335591]   Object 0xffff88004c03e140:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335602]   Object 0xffff88004c03e150:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335613]   Object 0xffff88004c03e160:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335623]   Object 0xffff88004c03e170:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335634]   Object 0xffff88004c03e180:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335645]   Object 0xffff88004c03e190:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335656]   Object 0xffff88004c03e1a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335666]   Object 0xffff88004c03e1b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335677]   Object 0xffff88004c03e1c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335688]   Object 0xffff88004c03e1d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[256058.335699]   Object 0xffff88004c03e1e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
[256058.335709]  Redzone 0xffff88004c03e1f0:  bb bb bb bb bb bb bb bb                         ��������        
[256058.335720]  Padding 0xffff88004c03e230:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
[256058.335731] Pid: 2692, comm: compiz Not tainted 2.6.38-rc4 #7
[256058.335733] Call Trace:
[256058.335739]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
[256058.335742]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
[256058.335744]  [<ffffffff81112bd9>] ? check_object+0xc5/0x1b0
[256058.335748]  [<ffffffff813c3f90>] ? sock_alloc_send_pskb+0xc0/0x2dd
[256058.335750]  [<ffffffff81112ede>] ? alloc_debug_processing+0x7f/0x120
[256058.335753]  [<ffffffff81113e78>] ? __slab_alloc+0x2c4/0x303
[256058.335756]  [<ffffffff813c737e>] ? __alloc_skb+0x47/0x13f
[256058.335758]  [<ffffffff813c3f90>] ? sock_alloc_send_pskb+0xc0/0x2dd
[256058.335761]  [<ffffffff81116062>] ? __kmalloc_node_track_caller+0xb8/0x11a
[256058.335764]  [<ffffffff813c3f90>] ? sock_alloc_send_pskb+0xc0/0x2dd
[256058.335767]  [<ffffffff813c73b3>] ? __alloc_skb+0x7c/0x13f
[256058.335771]  [<ffffffff8107f4c7>] ? arch_local_irq_save+0x18/0x1e
[256058.335774]  [<ffffffff813c3f90>] ? sock_alloc_send_pskb+0xc0/0x2dd
[256058.335777]  [<ffffffff813c41c2>] ? sock_alloc_send_skb+0x15/0x17
[256058.335781]  [<ffffffff814539ce>] ? unix_stream_sendmsg+0x11e/0x300
[256058.335785]  [<ffffffff813c00cb>] ? __sock_sendmsg+0x6b/0x77
[256058.335787]  [<ffffffff813c00d7>] ? sock_aio_write+0x0/0xd6
[256058.335790]  [<ffffffff813c0199>] ? sock_aio_write+0xc2/0xd6
[256058.335793]  [<ffffffff81125344>] ? do_sync_readv_writev+0xc1/0x100
[256058.335798]  [<ffffffff811f9f84>] ? selinux_file_permission+0xa3/0xb5
[256058.335802]  [<ffffffff811f2b47>] ? security_file_permission+0x2e/0x33
[256058.335805]  [<ffffffff811255a4>] ? do_readv_writev+0xa7/0x129
[256058.335808]  [<ffffffff811f2b47>] ? security_file_permission+0x2e/0x33
[256058.335810]  [<ffffffff8112566b>] ? vfs_writev+0x45/0x47
[256058.335813]  [<ffffffff8112578e>] ? sys_writev+0x4a/0x93
[256058.335816]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
[256058.335819] FIX kmalloc-512: Restoring 0xffff88004c03e018-0xffff88004c03e01f=0x6b
[256058.335820] 
[256058.335822] FIX kmalloc-512: Marking all objects used
[root@srv64 linux-2.6.38-rc4]# 

Feb 14 10:27:18 srv64 kernel: [256423.641129] =============================================================================
Feb 14 10:27:18 srv64 kernel: [256423.641133] BUG kmalloc-512: Redzone overwritten
Feb 14 10:27:18 srv64 kernel: [256423.641135] -----------------------------------------------------------------------------
Feb 14 10:27:18 srv64 kernel: [256423.641136] 
Feb 14 10:27:18 srv64 kernel: [256423.641138] INFO: 0xffff88004c03c690-0xffff88004c03c697. First byte 0xbb instead of 0xcc
Feb 14 10:27:18 srv64 kernel: [256423.641146] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113485464 cpu=0 pid=0
Feb 14 10:27:18 srv64 kernel: [256423.641149] INFO: Freed in skb_release_data+0xb0/0xb5 age=113470426 cpu=1 pid=11022
Feb 14 10:27:18 srv64 kernel: [256423.641152] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:27:18 srv64 kernel: [256423.641154] INFO: Object 0xffff88004c03c490 @offset=1168 fp=0xffff88004c03e6c8
Feb 14 10:27:18 srv64 kernel: [256423.641155] 
Feb 14 10:27:18 srv64 kernel: [256423.641157] Bytes b4 0xffff88004c03c480:  52 cb a2 01 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a Rˢ.....ZZZZZZZZ
Feb 14 10:27:18 srv64 kernel: [256423.641168]   Object 0xffff88004c03c490:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641179]   Object 0xffff88004c03c4a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641190]   Object 0xffff88004c03c4b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641201]   Object 0xffff88004c03c4c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641212]   Object 0xffff88004c03c4d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641223]   Object 0xffff88004c03c4e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641233]   Object 0xffff88004c03c4f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641244]   Object 0xffff88004c03c500:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641255]   Object 0xffff88004c03c510:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641266]   Object 0xffff88004c03c520:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641277]   Object 0xffff88004c03c530:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641288]   Object 0xffff88004c03c540:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641299]   Object 0xffff88004c03c550:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641310]   Object 0xffff88004c03c560:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641320]   Object 0xffff88004c03c570:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641331]   Object 0xffff88004c03c580:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641342]   Object 0xffff88004c03c590:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641353]   Object 0xffff88004c03c5a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641364]   Object 0xffff88004c03c5b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641375]   Object 0xffff88004c03c5c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641386]   Object 0xffff88004c03c5d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641397]   Object 0xffff88004c03c5e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641408]   Object 0xffff88004c03c5f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641419]   Object 0xffff88004c03c600:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641430]   Object 0xffff88004c03c610:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641441]   Object 0xffff88004c03c620:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641452]   Object 0xffff88004c03c630:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641462]   Object 0xffff88004c03c640:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641473]   Object 0xffff88004c03c650:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641484]   Object 0xffff88004c03c660:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641495]   Object 0xffff88004c03c670:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:27:18 srv64 kernel: [256423.641506]   Object 0xffff88004c03c680:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:27:18 srv64 kernel: [256423.641517]  Redzone 0xffff88004c03c690:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:27:18 srv64 kernel: [256423.641527]  Padding 0xffff88004c03c6d0:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:27:18 srv64 kernel: [256423.641539] Pid: 6423, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:27:18 srv64 kernel: [256423.641541] Call Trace:
Feb 14 10:27:18 srv64 kernel: [256423.641546]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:27:18 srv64 kernel: [256423.641549]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:27:18 srv64 kernel: [256423.641552]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:27:18 srv64 kernel: [256423.641554]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:27:18 srv64 kernel: [256423.641557]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:27:18 srv64 kernel: [256423.641560]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:27:18 srv64 kernel: [256423.641564]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:27:18 srv64 kernel: [256423.641568]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:27:18 srv64 kernel: [256423.641570]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:27:18 srv64 kernel: [256423.641573]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:27:18 srv64 kernel: [256423.641576]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:27:18 srv64 kernel: [256423.641579] FIX kmalloc-512: Restoring 0xffff88004c03c690-0xffff88004c03c697=0xcc
Feb 14 10:27:18 srv64 kernel: [256423.641580] 
Feb 14 10:28:28 srv64 kernel: [256493.536106] =============================================================================
Feb 14 10:28:28 srv64 kernel: [256493.536110] BUG kmalloc-512: Redzone overwritten
Feb 14 10:28:28 srv64 kernel: [256493.536112] -----------------------------------------------------------------------------
Feb 14 10:28:28 srv64 kernel: [256493.536113] 
Feb 14 10:28:28 srv64 kernel: [256493.536115] INFO: 0xffff88004c03c8d8-0xffff88004c03c8df. First byte 0xbb instead of 0xcc
Feb 14 10:28:28 srv64 kernel: [256493.536123] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113559135 cpu=0 pid=0
Feb 14 10:28:28 srv64 kernel: [256493.536126] INFO: Freed in skb_release_data+0xb0/0xb5 age=113546672 cpu=1 pid=11022
Feb 14 10:28:28 srv64 kernel: [256493.536129] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03f478 flags=0x20000000004081
Feb 14 10:28:28 srv64 kernel: [256493.536132] INFO: Object 0xffff88004c03c6d8 @offset=1752 fp=0xffff88004c03e910
Feb 14 10:28:28 srv64 kernel: [256493.536133] 
Feb 14 10:28:28 srv64 kernel: [256493.536134] Bytes b4 0xffff88004c03c6c8:  1f b7 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a .�......ZZZZZZZZ
Feb 14 10:28:28 srv64 kernel: [256493.536145]   Object 0xffff88004c03c6d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536156]   Object 0xffff88004c03c6e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536167]   Object 0xffff88004c03c6f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536178]   Object 0xffff88004c03c708:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536188]   Object 0xffff88004c03c718:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536199]   Object 0xffff88004c03c728:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536210]   Object 0xffff88004c03c738:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536221]   Object 0xffff88004c03c748:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536232]   Object 0xffff88004c03c758:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536242]   Object 0xffff88004c03c768:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536253]   Object 0xffff88004c03c778:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536264]   Object 0xffff88004c03c788:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536275]   Object 0xffff88004c03c798:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536286]   Object 0xffff88004c03c7a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536296]   Object 0xffff88004c03c7b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536307]   Object 0xffff88004c03c7c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536318]   Object 0xffff88004c03c7d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536329]   Object 0xffff88004c03c7e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536339]   Object 0xffff88004c03c7f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536350]   Object 0xffff88004c03c808:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536361]   Object 0xffff88004c03c818:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536372]   Object 0xffff88004c03c828:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536383]   Object 0xffff88004c03c838:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536393]   Object 0xffff88004c03c848:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536404]   Object 0xffff88004c03c858:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536415]   Object 0xffff88004c03c868:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536425]   Object 0xffff88004c03c878:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536436]   Object 0xffff88004c03c888:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536447]   Object 0xffff88004c03c898:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536458]   Object 0xffff88004c03c8a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536468]   Object 0xffff88004c03c8b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:28:28 srv64 kernel: [256493.536479]   Object 0xffff88004c03c8c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:28:28 srv64 kernel: [256493.536490]  Redzone 0xffff88004c03c8d8:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:28:28 srv64 kernel: [256493.536500]  Padding 0xffff88004c03c918:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:28:28 srv64 kernel: [256493.536512] Pid: 6430, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:28:28 srv64 kernel: [256493.536514] Call Trace:
Feb 14 10:28:28 srv64 kernel: [256493.536519]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:28:28 srv64 kernel: [256493.536522]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:28:28 srv64 kernel: [256493.536524]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:28:28 srv64 kernel: [256493.536527]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:28:28 srv64 kernel: [256493.536530]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:28:28 srv64 kernel: [256493.536533]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:28:28 srv64 kernel: [256493.536536]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:28:28 srv64 kernel: [256493.536540]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:28:28 srv64 kernel: [256493.536543]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:28:28 srv64 kernel: [256493.536545]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:28:28 srv64 kernel: [256493.536549]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:28:28 srv64 kernel: [256493.536552] FIX kmalloc-512: Restoring 0xffff88004c03c8d8-0xffff88004c03c8df=0xcc
Feb 14 10:28:28 srv64 kernel: [256493.536553] 
Feb 14 10:29:01 srv64 kernel: [256526.844850] =============================================================================
Feb 14 10:29:01 srv64 kernel: [256526.844854] BUG kmalloc-512: Redzone overwritten
Feb 14 10:29:01 srv64 kernel: [256526.844856] -----------------------------------------------------------------------------
Feb 14 10:29:01 srv64 kernel: [256526.844857] 
Feb 14 10:29:01 srv64 kernel: [256526.844859] INFO: 0xffff88004c03cb20-0xffff88004c03cb27. First byte 0xbb instead of 0xcc
Feb 14 10:29:01 srv64 kernel: [256526.844867] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113588242 cpu=0 pid=0
Feb 14 10:29:01 srv64 kernel: [256526.844871] INFO: Freed in skb_release_data+0xb0/0xb5 age=113572927 cpu=0 pid=11022
Feb 14 10:29:01 srv64 kernel: [256526.844873] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03f478 flags=0x20000000004081
Feb 14 10:29:01 srv64 kernel: [256526.844876] INFO: Object 0xffff88004c03c920 @offset=2336 fp=0xffff88004c03c490
Feb 14 10:29:01 srv64 kernel: [256526.844877] 
Feb 14 10:29:01 srv64 kernel: [256526.844878] Bytes b4 0xffff88004c03c910:  4f 9e 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a O.......ZZZZZZZZ
Feb 14 10:29:01 srv64 kernel: [256526.844889]   Object 0xffff88004c03c920:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.844900]   Object 0xffff88004c03c930:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.844911]   Object 0xffff88004c03c940:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.844922]   Object 0xffff88004c03c950:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.844932]   Object 0xffff88004c03c960:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.844943]   Object 0xffff88004c03c970:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.844954]   Object 0xffff88004c03c980:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.844965]   Object 0xffff88004c03c990:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.844976]   Object 0xffff88004c03c9a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.844987]   Object 0xffff88004c03c9b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.844997]   Object 0xffff88004c03c9c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845008]   Object 0xffff88004c03c9d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845019]   Object 0xffff88004c03c9e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845030]   Object 0xffff88004c03c9f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845041]   Object 0xffff88004c03ca00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845051]   Object 0xffff88004c03ca10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845062]   Object 0xffff88004c03ca20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845073]   Object 0xffff88004c03ca30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845084]   Object 0xffff88004c03ca40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845095]   Object 0xffff88004c03ca50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845106]   Object 0xffff88004c03ca60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845116]   Object 0xffff88004c03ca70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845127]   Object 0xffff88004c03ca80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845138]   Object 0xffff88004c03ca90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845149]   Object 0xffff88004c03caa0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845160]   Object 0xffff88004c03cab0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845171]   Object 0xffff88004c03cac0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845181]   Object 0xffff88004c03cad0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845192]   Object 0xffff88004c03cae0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845203]   Object 0xffff88004c03caf0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845214]   Object 0xffff88004c03cb00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:01 srv64 kernel: [256526.845225]   Object 0xffff88004c03cb10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:29:01 srv64 kernel: [256526.845236]  Redzone 0xffff88004c03cb20:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:29:01 srv64 kernel: [256526.845246]  Padding 0xffff88004c03cb60:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:29:01 srv64 kernel: [256526.845258] Pid: 6439, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:29:01 srv64 kernel: [256526.845260] Call Trace:
Feb 14 10:29:01 srv64 kernel: [256526.845265]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:29:01 srv64 kernel: [256526.845268]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:29:01 srv64 kernel: [256526.845271]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:29:01 srv64 kernel: [256526.845273]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:29:01 srv64 kernel: [256526.845276]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:29:01 srv64 kernel: [256526.845279]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:29:01 srv64 kernel: [256526.845283]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:29:01 srv64 kernel: [256526.845287]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:29:01 srv64 kernel: [256526.845289]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:29:01 srv64 kernel: [256526.845292]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:29:01 srv64 kernel: [256526.845295]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:29:01 srv64 kernel: [256526.845298] FIX kmalloc-512: Restoring 0xffff88004c03cb20-0xffff88004c03cb27=0xcc
Feb 14 10:29:01 srv64 kernel: [256526.845299] 
Feb 14 10:29:29 srv64 kernel: [256554.871370] =============================================================================
Feb 14 10:29:29 srv64 kernel: [256554.871374] BUG kmalloc-512: Redzone overwritten
Feb 14 10:29:29 srv64 kernel: [256554.871375] -----------------------------------------------------------------------------
Feb 14 10:29:29 srv64 kernel: [256554.871377] 
Feb 14 10:29:29 srv64 kernel: [256554.871379] INFO: 0xffff88004c03cd68-0xffff88004c03cd6f. First byte 0xbb instead of 0xcc
Feb 14 10:29:29 srv64 kernel: [256554.871386] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113620069 cpu=0 pid=0
Feb 14 10:29:29 srv64 kernel: [256554.871390] INFO: Freed in skb_release_data+0xb0/0xb5 age=113607328 cpu=1 pid=11022
Feb 14 10:29:29 srv64 kernel: [256554.871392] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03f478 flags=0x20000000004081
Feb 14 10:29:29 srv64 kernel: [256554.871395] INFO: Object 0xffff88004c03cb68 @offset=2920 fp=0xffff88004c03dda8
Feb 14 10:29:29 srv64 kernel: [256554.871396] 
Feb 14 10:29:29 srv64 kernel: [256554.871397] Bytes b4 0xffff88004c03cb58:  dd b9 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a ݹ......ZZZZZZZZ
Feb 14 10:29:29 srv64 kernel: [256554.871408]   Object 0xffff88004c03cb68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871419]   Object 0xffff88004c03cb78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871430]   Object 0xffff88004c03cb88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871441]   Object 0xffff88004c03cb98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871452]   Object 0xffff88004c03cba8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871463]   Object 0xffff88004c03cbb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871474]   Object 0xffff88004c03cbc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871485]   Object 0xffff88004c03cbd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871495]   Object 0xffff88004c03cbe8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871506]   Object 0xffff88004c03cbf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871517]   Object 0xffff88004c03cc08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871528]   Object 0xffff88004c03cc18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871539]   Object 0xffff88004c03cc28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871550]   Object 0xffff88004c03cc38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871561]   Object 0xffff88004c03cc48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871572]   Object 0xffff88004c03cc58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871583]   Object 0xffff88004c03cc68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871594]   Object 0xffff88004c03cc78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871605]   Object 0xffff88004c03cc88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871616]   Object 0xffff88004c03cc98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871626]   Object 0xffff88004c03cca8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871637]   Object 0xffff88004c03ccb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871648]   Object 0xffff88004c03ccc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871659]   Object 0xffff88004c03ccd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871670]   Object 0xffff88004c03cce8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871681]   Object 0xffff88004c03ccf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871692]   Object 0xffff88004c03cd08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871703]   Object 0xffff88004c03cd18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871713]   Object 0xffff88004c03cd28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871724]   Object 0xffff88004c03cd38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871735]   Object 0xffff88004c03cd48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:29 srv64 kernel: [256554.871746]   Object 0xffff88004c03cd58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:29:29 srv64 kernel: [256554.871757]  Redzone 0xffff88004c03cd68:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:29:29 srv64 kernel: [256554.871768]  Padding 0xffff88004c03cda8:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:29:29 srv64 kernel: [256554.871779] Pid: 6440, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:29:29 srv64 kernel: [256554.871781] Call Trace:
Feb 14 10:29:29 srv64 kernel: [256554.871786]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:29:29 srv64 kernel: [256554.871789]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:29:29 srv64 kernel: [256554.871792]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:29:29 srv64 kernel: [256554.871795]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:29:29 srv64 kernel: [256554.871798]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:29:29 srv64 kernel: [256554.871801]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:29:29 srv64 kernel: [256554.871804]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:29:29 srv64 kernel: [256554.871808]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:29:29 srv64 kernel: [256554.871811]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:29:29 srv64 kernel: [256554.871813]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:29:29 srv64 kernel: [256554.871817]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:29:29 srv64 kernel: [256554.871820] FIX kmalloc-512: Restoring 0xffff88004c03cd68-0xffff88004c03cd6f=0xcc
Feb 14 10:29:29 srv64 kernel: [256554.871821] 
Feb 14 10:29:43 srv64 kernel: [256568.754674] =============================================================================
Feb 14 10:29:43 srv64 kernel: [256568.754678] BUG kmalloc-512: Redzone overwritten
Feb 14 10:29:43 srv64 kernel: [256568.754680] -----------------------------------------------------------------------------
Feb 14 10:29:43 srv64 kernel: [256568.754681] 
Feb 14 10:29:43 srv64 kernel: [256568.754683] INFO: 0xffff88004c03cfb0-0xffff88004c03cfb7. First byte 0xbb instead of 0xcc
Feb 14 10:29:43 srv64 kernel: [256568.754691] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113631423 cpu=0 pid=0
Feb 14 10:29:43 srv64 kernel: [256568.754694] INFO: Freed in skb_release_data+0xb0/0xb5 age=113616202 cpu=1 pid=11022
Feb 14 10:29:43 srv64 kernel: [256568.754697] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:29:43 srv64 kernel: [256568.754699] INFO: Object 0xffff88004c03cdb0 @offset=3504 fp=0xffff88004c03d918
Feb 14 10:29:43 srv64 kernel: [256568.754700] 
Feb 14 10:29:43 srv64 kernel: [256568.754702] Bytes b4 0xffff88004c03cda0:  f7 a0 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a �.......ZZZZZZZZ
Feb 14 10:29:43 srv64 kernel: [256568.754713]   Object 0xffff88004c03cdb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754724]   Object 0xffff88004c03cdc0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754734]   Object 0xffff88004c03cdd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754745]   Object 0xffff88004c03cde0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754756]   Object 0xffff88004c03cdf0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754767]   Object 0xffff88004c03ce00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754778]   Object 0xffff88004c03ce10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754789]   Object 0xffff88004c03ce20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754799]   Object 0xffff88004c03ce30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754810]   Object 0xffff88004c03ce40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754821]   Object 0xffff88004c03ce50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754832]   Object 0xffff88004c03ce60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754843]   Object 0xffff88004c03ce70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754853]   Object 0xffff88004c03ce80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754864]   Object 0xffff88004c03ce90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754875]   Object 0xffff88004c03cea0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754886]   Object 0xffff88004c03ceb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754897]   Object 0xffff88004c03cec0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754907]   Object 0xffff88004c03ced0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754918]   Object 0xffff88004c03cee0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754929]   Object 0xffff88004c03cef0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754940]   Object 0xffff88004c03cf00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754951]   Object 0xffff88004c03cf10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754962]   Object 0xffff88004c03cf20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754972]   Object 0xffff88004c03cf30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754983]   Object 0xffff88004c03cf40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.754994]   Object 0xffff88004c03cf50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.755005]   Object 0xffff88004c03cf60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.755016]   Object 0xffff88004c03cf70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.755027]   Object 0xffff88004c03cf80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.755038]   Object 0xffff88004c03cf90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:29:43 srv64 kernel: [256568.755049]   Object 0xffff88004c03cfa0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:29:43 srv64 kernel: [256568.755059]  Redzone 0xffff88004c03cfb0:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:29:43 srv64 kernel: [256568.755070]  Padding 0xffff88004c03cff0:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:29:43 srv64 kernel: [256568.755081] Pid: 6443, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:29:43 srv64 kernel: [256568.755083] Call Trace:
Feb 14 10:29:43 srv64 kernel: [256568.755088]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:29:43 srv64 kernel: [256568.755091]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:29:43 srv64 kernel: [256568.755094]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:29:43 srv64 kernel: [256568.755096]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:29:43 srv64 kernel: [256568.755099]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:29:43 srv64 kernel: [256568.755102]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:29:43 srv64 kernel: [256568.755106]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:29:43 srv64 kernel: [256568.755110]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:29:43 srv64 kernel: [256568.755112]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:29:43 srv64 kernel: [256568.755115]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:29:43 srv64 kernel: [256568.755118]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:29:43 srv64 kernel: [256568.755121] FIX kmalloc-512: Restoring 0xffff88004c03cfb0-0xffff88004c03cfb7=0xcc
Feb 14 10:29:43 srv64 kernel: [256568.755122] 
Feb 14 10:30:07 srv64 kernel: [256592.688424] =============================================================================
Feb 14 10:30:07 srv64 kernel: [256592.688428] BUG kmalloc-512: Redzone overwritten
Feb 14 10:30:07 srv64 kernel: [256592.688430] -----------------------------------------------------------------------------
Feb 14 10:30:07 srv64 kernel: [256592.688431] 
Feb 14 10:30:07 srv64 kernel: [256592.688433] INFO: 0xffff88004c03d440-0xffff88004c03d447. First byte 0xbb instead of 0xcc
Feb 14 10:30:07 srv64 kernel: [256592.688440] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113656868 cpu=0 pid=0
Feb 14 10:30:07 srv64 kernel: [256592.688444] INFO: Freed in skb_release_data+0xb0/0xb5 age=113643714 cpu=1 pid=11022
Feb 14 10:30:07 srv64 kernel: [256592.688446] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:30:07 srv64 kernel: [256592.688449] INFO: Object 0xffff88004c03d240 @offset=4672 fp=0xffff88004c03d488
Feb 14 10:30:07 srv64 kernel: [256592.688450] 
Feb 14 10:30:07 srv64 kernel: [256592.688451] Bytes b4 0xffff88004c03d230:  72 50 46 0f 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a rPF.....ZZZZZZZZ
Feb 14 10:30:07 srv64 kernel: [256592.688463]   Object 0xffff88004c03d240:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688473]   Object 0xffff88004c03d250:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688484]   Object 0xffff88004c03d260:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688495]   Object 0xffff88004c03d270:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688506]   Object 0xffff88004c03d280:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688516]   Object 0xffff88004c03d290:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688527]   Object 0xffff88004c03d2a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688538]   Object 0xffff88004c03d2b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688549]   Object 0xffff88004c03d2c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688560]   Object 0xffff88004c03d2d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688570]   Object 0xffff88004c03d2e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688581]   Object 0xffff88004c03d2f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688592]   Object 0xffff88004c03d300:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688603]   Object 0xffff88004c03d310:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688614]   Object 0xffff88004c03d320:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688625]   Object 0xffff88004c03d330:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688636]   Object 0xffff88004c03d340:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688646]   Object 0xffff88004c03d350:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688657]   Object 0xffff88004c03d360:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688668]   Object 0xffff88004c03d370:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688679]   Object 0xffff88004c03d380:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688690]   Object 0xffff88004c03d390:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688700]   Object 0xffff88004c03d3a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688711]   Object 0xffff88004c03d3b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688722]   Object 0xffff88004c03d3c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688733]   Object 0xffff88004c03d3d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688744]   Object 0xffff88004c03d3e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688754]   Object 0xffff88004c03d3f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688765]   Object 0xffff88004c03d400:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688776]   Object 0xffff88004c03d410:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688787]   Object 0xffff88004c03d420:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:07 srv64 kernel: [256592.688798]   Object 0xffff88004c03d430:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:30:07 srv64 kernel: [256592.688809]  Redzone 0xffff88004c03d440:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:30:07 srv64 kernel: [256592.688819]  Padding 0xffff88004c03d480:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:30:07 srv64 kernel: [256592.688831] Pid: 6450, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:30:07 srv64 kernel: [256592.688833] Call Trace:
Feb 14 10:30:07 srv64 kernel: [256592.688838]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:30:07 srv64 kernel: [256592.688841]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:30:07 srv64 kernel: [256592.688843]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:30:07 srv64 kernel: [256592.688846]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:30:07 srv64 kernel: [256592.688849]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:30:07 srv64 kernel: [256592.688852]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:30:07 srv64 kernel: [256592.688855]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:30:07 srv64 kernel: [256592.688859]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:30:07 srv64 kernel: [256592.688862]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:30:07 srv64 kernel: [256592.688864]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:30:07 srv64 kernel: [256592.688868]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:30:07 srv64 kernel: [256592.688871] FIX kmalloc-512: Restoring 0xffff88004c03d440-0xffff88004c03d447=0xcc
Feb 14 10:30:07 srv64 kernel: [256592.688872] 
Feb 14 10:30:30 srv64 kernel: [256616.072001] SLUB filp: Skipped busy slab 0xffffea000045bed0
Feb 14 10:30:30 srv64 kernel: [256616.108670] =============================================================================
Feb 14 10:30:30 srv64 kernel: [256616.108674] BUG kmalloc-512: Redzone overwritten
Feb 14 10:30:30 srv64 kernel: [256616.108676] -----------------------------------------------------------------------------
Feb 14 10:30:30 srv64 kernel: [256616.108677] 
Feb 14 10:30:30 srv64 kernel: [256616.108679] INFO: 0xffff88004c03d688-0xffff88004c03d68f. First byte 0xbb instead of 0xcc
Feb 14 10:30:30 srv64 kernel: [256616.108687] INFO: Allocated in alloc_skb+0x13/0x15 age=113680366 cpu=0 pid=0
Feb 14 10:30:30 srv64 kernel: [256616.108690] INFO: Freed in skb_release_data+0xb0/0xb5 age=113667134 cpu=1 pid=11022
Feb 14 10:30:30 srv64 kernel: [256616.108693] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:30:30 srv64 kernel: [256616.108695] INFO: Object 0xffff88004c03d488 @offset=5256 fp=0xffff88004c03e480
Feb 14 10:30:30 srv64 kernel: [256616.108696] 
Feb 14 10:30:30 srv64 kernel: [256616.108698] Bytes b4 0xffff88004c03d478:  8e a6 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a .�......ZZZZZZZZ
Feb 14 10:30:30 srv64 kernel: [256616.108709]   Object 0xffff88004c03d488:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108720]   Object 0xffff88004c03d498:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108731]   Object 0xffff88004c03d4a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108742]   Object 0xffff88004c03d4b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108753]   Object 0xffff88004c03d4c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108764]   Object 0xffff88004c03d4d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108775]   Object 0xffff88004c03d4e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108786]   Object 0xffff88004c03d4f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108797]   Object 0xffff88004c03d508:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108808]   Object 0xffff88004c03d518:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108819]   Object 0xffff88004c03d528:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108830]   Object 0xffff88004c03d538:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108841]   Object 0xffff88004c03d548:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108852]   Object 0xffff88004c03d558:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108863]   Object 0xffff88004c03d568:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108874]   Object 0xffff88004c03d578:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108884]   Object 0xffff88004c03d588:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108895]   Object 0xffff88004c03d598:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108906]   Object 0xffff88004c03d5a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108917]   Object 0xffff88004c03d5b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108928]   Object 0xffff88004c03d5c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108939]   Object 0xffff88004c03d5d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108950]   Object 0xffff88004c03d5e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108961]   Object 0xffff88004c03d5f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108972]   Object 0xffff88004c03d608:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108983]   Object 0xffff88004c03d618:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.108994]   Object 0xffff88004c03d628:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.109005]   Object 0xffff88004c03d638:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.109015]   Object 0xffff88004c03d648:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.109026]   Object 0xffff88004c03d658:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.109037]   Object 0xffff88004c03d668:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:30 srv64 kernel: [256616.109048]   Object 0xffff88004c03d678:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:30:30 srv64 kernel: [256616.109059]  Redzone 0xffff88004c03d688:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:30:30 srv64 kernel: [256616.109070]  Padding 0xffff88004c03d6c8:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:30:30 srv64 kernel: [256616.109081] Pid: 6451, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:30:30 srv64 kernel: [256616.109083] Call Trace:
Feb 14 10:30:30 srv64 kernel: [256616.109088]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:30:30 srv64 kernel: [256616.109091]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:30:30 srv64 kernel: [256616.109094]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:30:30 srv64 kernel: [256616.109096]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:30:30 srv64 kernel: [256616.109099]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:30:30 srv64 kernel: [256616.109102]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:30:30 srv64 kernel: [256616.109106]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:30:30 srv64 kernel: [256616.109110]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:30:30 srv64 kernel: [256616.109112]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:30:30 srv64 kernel: [256616.109115]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:30:30 srv64 kernel: [256616.109119]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:30:30 srv64 kernel: [256616.109121] FIX kmalloc-512: Restoring 0xffff88004c03d688-0xffff88004c03d68f=0xcc
Feb 14 10:30:30 srv64 kernel: [256616.109122] 
kernel: [256644.959144] =============================================================================
Feb 14 10:30:59 srv64 kernel: [256644.959149] BUG kmalloc-512: Redzone overwritten
Feb 14 10:30:59 srv64 kernel: [256644.959151] -----------------------------------------------------------------------------
Feb 14 10:30:59 srv64 kernel: [256644.959152] 
Feb 14 10:30:59 srv64 kernel: [256644.959155] INFO: 0xffff88004c03d8d0-0xffff88004c03d8d7. First byte 0xbb instead of 0xcc
Feb 14 10:30:59 srv64 kernel: [256644.959165] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113705767 cpu=0 pid=0
Feb 14 10:30:59 srv64 kernel: [256644.959168] INFO: Freed in skb_release_data+0xb0/0xb5 age=113688873 cpu=1 pid=11022
Feb 14 10:30:59 srv64 kernel: [256644.959171] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:30:59 srv64 kernel: [256644.959173] INFO: Object 0xffff88004c03d6d0 @offset=5840 fp=0xffff88004c03f6c0
Feb 14 10:30:59 srv64 kernel: [256644.959174] 
Feb 14 10:30:59 srv64 kernel: [256644.959175] Bytes b4 0xffff88004c03d6c0:  8e a6 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a .�......ZZZZZZZZ
Feb 14 10:30:59 srv64 kernel: [256644.959187]   Object 0xffff88004c03d6d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959198]   Object 0xffff88004c03d6e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959209]   Object 0xffff88004c03d6f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959220]   Object 0xffff88004c03d700:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959231]   Object 0xffff88004c03d710:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959241]   Object 0xffff88004c03d720:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959252]   Object 0xffff88004c03d730:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959263]   Object 0xffff88004c03d740:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959274]   Object 0xffff88004c03d750:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959285]   Object 0xffff88004c03d760:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959296]   Object 0xffff88004c03d770:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959307]   Object 0xffff88004c03d780:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959318]   Object 0xffff88004c03d790:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959329]   Object 0xffff88004c03d7a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959340]   Object 0xffff88004c03d7b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959351]   Object 0xffff88004c03d7c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959362]   Object 0xffff88004c03d7d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959373]   Object 0xffff88004c03d7e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959383]   Object 0xffff88004c03d7f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959394]   Object 0xffff88004c03d800:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959405]   Object 0xffff88004c03d810:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959416]   Object 0xffff88004c03d820:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959427]   Object 0xffff88004c03d830:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959438]   Object 0xffff88004c03d840:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959449]   Object 0xffff88004c03d850:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959460]   Object 0xffff88004c03d860:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959471]   Object 0xffff88004c03d870:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959482]   Object 0xffff88004c03d880:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959493]   Object 0xffff88004c03d890:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959503]   Object 0xffff88004c03d8a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959514]   Object 0xffff88004c03d8b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:30:59 srv64 kernel: [256644.959525]   Object 0xffff88004c03d8c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:30:59 srv64 kernel: [256644.959536]  Redzone 0xffff88004c03d8d0:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:30:59 srv64 kernel: [256644.959547]  Padding 0xffff88004c03d910:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:30:59 srv64 kernel: [256644.959558] Pid: 6459, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:30:59 srv64 kernel: [256644.959560] Call Trace:
Feb 14 10:30:59 srv64 kernel: [256644.959566]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:30:59 srv64 kernel: [256644.959569]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:30:59 srv64 kernel: [256644.959571]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:30:59 srv64 kernel: [256644.959574]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:30:59 srv64 kernel: [256644.959577]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:30:59 srv64 kernel: [256644.959580]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:30:59 srv64 kernel: [256644.959583]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:30:59 srv64 kernel: [256644.959588]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:30:59 srv64 kernel: [256644.959590]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:30:59 srv64 kernel: [256644.959593]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:30:59 srv64 kernel: [256644.959597]  [<ffffffff8100ae97>] ? tracesys+0xd9/0xde
Feb 14 10:30:59 srv64 kernel: [256644.959599] FIX kmalloc-512: Restoring 0xffff88004c03d8d0-0xffff88004c03d8d7=0xcc
Feb 14 10:30:59 srv64 kernel: [256644.959600] 
Feb 14 10:31:13 srv64 kernel: [256659.358338] =============================================================================
Feb 14 10:31:13 srv64 kernel: [256659.358342] BUG kmalloc-512: Redzone overwritten
Feb 14 10:31:13 srv64 kernel: [256659.358344] -----------------------------------------------------------------------------
Feb 14 10:31:13 srv64 kernel: [256659.358345] 
Feb 14 10:31:13 srv64 kernel: [256659.358348] INFO: 0xffff88004c03db18-0xffff88004c03db1f. First byte 0xbb instead of 0xcc
Feb 14 10:31:13 srv64 kernel: [256659.358355] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113722464 cpu=0 pid=0
Feb 14 10:31:13 srv64 kernel: [256659.358358] INFO: Freed in skb_release_data+0xb0/0xb5 age=113708210 cpu=1 pid=11022
Feb 14 10:31:13 srv64 kernel: [256659.358361] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:31:13 srv64 kernel: [256659.358363] INFO: Object 0xffff88004c03d918 @offset=6424 fp=0xffff88004c03efe8
Feb 14 10:31:13 srv64 kernel: [256659.358364] 
Feb 14 10:31:13 srv64 kernel: [256659.358366] Bytes b4 0xffff88004c03d908:  56 c2 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a V�......ZZZZZZZZ
Feb 14 10:31:13 srv64 kernel: [256659.358377]   Object 0xffff88004c03d918:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358388]   Object 0xffff88004c03d928:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358399]   Object 0xffff88004c03d938:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358409]   Object 0xffff88004c03d948:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358420]   Object 0xffff88004c03d958:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358431]   Object 0xffff88004c03d968:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358442]   Object 0xffff88004c03d978:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358453]   Object 0xffff88004c03d988:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358463]   Object 0xffff88004c03d998:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358474]   Object 0xffff88004c03d9a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358485]   Object 0xffff88004c03d9b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358496]   Object 0xffff88004c03d9c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358507]   Object 0xffff88004c03d9d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358517]   Object 0xffff88004c03d9e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358528]   Object 0xffff88004c03d9f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358539]   Object 0xffff88004c03da08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358550]   Object 0xffff88004c03da18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358561]   Object 0xffff88004c03da28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358572]   Object 0xffff88004c03da38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358583]   Object 0xffff88004c03da48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358593]   Object 0xffff88004c03da58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358604]   Object 0xffff88004c03da68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358615]   Object 0xffff88004c03da78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358626]   Object 0xffff88004c03da88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358637]   Object 0xffff88004c03da98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358648]   Object 0xffff88004c03daa8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358658]   Object 0xffff88004c03dab8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358669]   Object 0xffff88004c03dac8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358680]   Object 0xffff88004c03dad8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358691]   Object 0xffff88004c03dae8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358702]   Object 0xffff88004c03daf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:31:13 srv64 kernel: [256659.358713]   Object 0xffff88004c03db08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:31:13 srv64 kernel: [256659.358723]  Redzone 0xffff88004c03db18:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:31:13 srv64 kernel: [256659.358734]  Padding 0xffff88004c03db58:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:31:13 srv64 kernel: [256659.358745] Pid: 6463, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:31:13 srv64 kernel: [256659.358747] Call Trace:
Feb 14 10:31:13 srv64 kernel: [256659.358752]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:31:13 srv64 kernel: [256659.358755]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:31:13 srv64 kernel: [256659.358758]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:31:13 srv64 kernel: [256659.358760]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:31:13 srv64 kernel: [256659.358763]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:31:13 srv64 kernel: [256659.358766]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:31:13 srv64 kernel: [256659.358770]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:31:13 srv64 kernel: [256659.358774]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:31:13 srv64 kernel: [256659.358776]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:31:13 srv64 kernel: [256659.358779]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:31:13 srv64 kernel: [256659.358782]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:31:13 srv64 kernel: [256659.358785] FIX kmalloc-512: Restoring 0xffff88004c03db18-0xffff88004c03db1f=0xcc
Feb 14 10:31:13 srv64 kernel: [256659.358786] 
Feb 14 10:32:19 srv64 kernel: [256724.786277] =============================================================================
Feb 14 10:32:19 srv64 kernel: [256724.786282] BUG kmalloc-512: Redzone overwritten
Feb 14 10:32:19 srv64 kernel: [256724.786283] -----------------------------------------------------------------------------
Feb 14 10:32:19 srv64 kernel: [256724.786285] 
Feb 14 10:32:19 srv64 kernel: [256724.786287] INFO: 0xffff88004c03dd60-0xffff88004c03dd67. First byte 0xbb instead of 0xcc
Feb 14 10:32:19 srv64 kernel: [256724.786294] INFO: Allocated in alloc_skb+0x13/0x15 age=113788966 cpu=0 pid=0
Feb 14 10:32:19 srv64 kernel: [256724.786298] INFO: Freed in skb_release_data+0xb0/0xb5 age=113775811 cpu=1 pid=11022
Feb 14 10:32:19 srv64 kernel: [256724.786300] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:32:19 srv64 kernel: [256724.786302] INFO: Object 0xffff88004c03db60 @offset=7008 fp=0xffff88004c03d240
Feb 14 10:32:19 srv64 kernel: [256724.786303] 
Feb 14 10:32:19 srv64 kernel: [256724.786305] Bytes b4 0xffff88004c03db50:  0c af 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a .�......ZZZZZZZZ
Feb 14 10:32:19 srv64 kernel: [256724.786316]   Object 0xffff88004c03db60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786327]   Object 0xffff88004c03db70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786338]   Object 0xffff88004c03db80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786349]   Object 0xffff88004c03db90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786360]   Object 0xffff88004c03dba0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786370]   Object 0xffff88004c03dbb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786381]   Object 0xffff88004c03dbc0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786392]   Object 0xffff88004c03dbd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786403]   Object 0xffff88004c03dbe0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786414]   Object 0xffff88004c03dbf0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786424]   Object 0xffff88004c03dc00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786435]   Object 0xffff88004c03dc10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786446]   Object 0xffff88004c03dc20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786457]   Object 0xffff88004c03dc30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786467]   Object 0xffff88004c03dc40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786478]   Object 0xffff88004c03dc50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786489]   Object 0xffff88004c03dc60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786500]   Object 0xffff88004c03dc70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786510]   Object 0xffff88004c03dc80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786521]   Object 0xffff88004c03dc90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786532]   Object 0xffff88004c03dca0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786543]   Object 0xffff88004c03dcb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786553]   Object 0xffff88004c03dcc0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786564]   Object 0xffff88004c03dcd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786575]   Object 0xffff88004c03dce0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786586]   Object 0xffff88004c03dcf0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786596]   Object 0xffff88004c03dd00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786607]   Object 0xffff88004c03dd10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786618]   Object 0xffff88004c03dd20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786629]   Object 0xffff88004c03dd30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786640]   Object 0xffff88004c03dd40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:19 srv64 kernel: [256724.786650]   Object 0xffff88004c03dd50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:32:19 srv64 kernel: [256724.786661]  Redzone 0xffff88004c03dd60:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:32:19 srv64 kernel: [256724.786672]  Padding 0xffff88004c03dda0:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:32:19 srv64 kernel: [256724.786683] Pid: 6471, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:32:19 srv64 kernel: [256724.786685] Call Trace:
Feb 14 10:32:19 srv64 kernel: [256724.786690]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:32:19 srv64 kernel: [256724.786692]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:32:19 srv64 kernel: [256724.786695]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:32:19 srv64 kernel: [256724.786698]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:32:19 srv64 kernel: [256724.786701]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:32:19 srv64 kernel: [256724.786704]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:32:19 srv64 kernel: [256724.786707]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:32:19 srv64 kernel: [256724.786711]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:32:19 srv64 kernel: [256724.786714]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:32:19 srv64 kernel: [256724.786716]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:32:19 srv64 kernel: [256724.786720]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:32:19 srv64 kernel: [256724.786722] FIX kmalloc-512: Restoring 0xffff88004c03dd60-0xffff88004c03dd67=0xcc
Feb 14 10:32:19 srv64 kernel: [256724.786723] 
Feb 14 10:32:31 srv64 kernel: [256736.433920] =============================================================================
Feb 14 10:32:31 srv64 kernel: [256736.433924] BUG kmalloc-512: Redzone overwritten
Feb 14 10:32:31 srv64 kernel: [256736.433926] -----------------------------------------------------------------------------
Feb 14 10:32:31 srv64 kernel: [256736.433927] 
Feb 14 10:32:31 srv64 kernel: [256736.433929] INFO: 0xffff88004c03dfa8-0xffff88004c03dfaf. First byte 0xbb instead of 0xcc
Feb 14 10:32:31 srv64 kernel: [256736.433936] INFO: Allocated in alloc_skb+0x13/0x15 age=113802033 cpu=0 pid=0
Feb 14 10:32:31 srv64 kernel: [256736.433940] INFO: Freed in skb_release_data+0xb0/0xb5 age=113789570 cpu=1 pid=11022
Feb 14 10:32:31 srv64 kernel: [256736.433942] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:32:31 srv64 kernel: [256736.433945] INFO: Object 0xffff88004c03dda8 @offset=7592 fp=0xffff88004c03c6d8
Feb 14 10:32:31 srv64 kernel: [256736.433946] 
Feb 14 10:32:31 srv64 kernel: [256736.433947] Bytes b4 0xffff88004c03dd98:  8f a6 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a .�......ZZZZZZZZ
Feb 14 10:32:31 srv64 kernel: [256736.433959]   Object 0xffff88004c03dda8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.433970]   Object 0xffff88004c03ddb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.433980]   Object 0xffff88004c03ddc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.433991]   Object 0xffff88004c03ddd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434002]   Object 0xffff88004c03dde8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434013]   Object 0xffff88004c03ddf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434024]   Object 0xffff88004c03de08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434034]   Object 0xffff88004c03de18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434045]   Object 0xffff88004c03de28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434056]   Object 0xffff88004c03de38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434067]   Object 0xffff88004c03de48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434077]   Object 0xffff88004c03de58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434088]   Object 0xffff88004c03de68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434099]   Object 0xffff88004c03de78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434110]   Object 0xffff88004c03de88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434121]   Object 0xffff88004c03de98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434132]   Object 0xffff88004c03dea8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434142]   Object 0xffff88004c03deb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434153]   Object 0xffff88004c03dec8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434164]   Object 0xffff88004c03ded8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434175]   Object 0xffff88004c03dee8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434186]   Object 0xffff88004c03def8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434196]   Object 0xffff88004c03df08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434207]   Object 0xffff88004c03df18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434218]   Object 0xffff88004c03df28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434229]   Object 0xffff88004c03df38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434240]   Object 0xffff88004c03df48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434251]   Object 0xffff88004c03df58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434261]   Object 0xffff88004c03df68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434272]   Object 0xffff88004c03df78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434283]   Object 0xffff88004c03df88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:31 srv64 kernel: [256736.434294]   Object 0xffff88004c03df98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:32:31 srv64 kernel: [256736.434305]  Redzone 0xffff88004c03dfa8:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:32:31 srv64 kernel: [256736.434315]  Padding 0xffff88004c03dfe8:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:32:31 srv64 kernel: [256736.434327] Pid: 6474, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:32:31 srv64 kernel: [256736.434328] Call Trace:
Feb 14 10:32:31 srv64 kernel: [256736.434333]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:32:31 srv64 kernel: [256736.434336]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:32:31 srv64 kernel: [256736.434339]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:32:31 srv64 kernel: [256736.434342]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:32:31 srv64 kernel: [256736.434345]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:32:31 srv64 kernel: [256736.434348]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:32:31 srv64 kernel: [256736.434351]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:32:31 srv64 kernel: [256736.434355]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:32:31 srv64 kernel: [256736.434358]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:32:31 srv64 kernel: [256736.434360]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:32:31 srv64 kernel: [256736.434364]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:32:31 srv64 kernel: [256736.434366] FIX kmalloc-512: Restoring 0xffff88004c03dfa8-0xffff88004c03dfaf=0xcc
Feb 14 10:32:31 srv64 kernel: [256736.434367] 
Feb 14 10:32:42 srv64 kernel: [256747.549151] =============================================================================
Feb 14 10:32:42 srv64 kernel: [256747.549156] BUG kmalloc-512: Redzone overwritten
Feb 14 10:32:42 srv64 kernel: [256747.549158] -----------------------------------------------------------------------------
Feb 14 10:32:42 srv64 kernel: [256747.549159] 
Feb 14 10:32:42 srv64 kernel: [256747.549161] INFO: 0xffff88004c03e1f0-0xffff88004c03e1f7. First byte 0xbb instead of 0xcc
Feb 14 10:32:42 srv64 kernel: [256747.549168] INFO: Allocated in alloc_skb+0x13/0x15 age=113808357 cpu=0 pid=0
Feb 14 10:32:42 srv64 kernel: [256747.549172] INFO: Freed in skb_release_data+0xb0/0xb5 age=113791463 cpu=1 pid=11022
Feb 14 10:32:42 srv64 kernel: [256747.549174] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:32:42 srv64 kernel: [256747.549177] INFO: Object 0xffff88004c03dff0 @offset=8176 fp=0xffff88004c03d6d0
Feb 14 10:32:42 srv64 kernel: [256747.549178] 
Feb 14 10:32:42 srv64 kernel: [256747.549180] Bytes b4 0xffff88004c03dfe0:  4f 9e 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a O.......ZZZZZZZZ
Feb 14 10:32:42 srv64 kernel: [256747.549191]   Object 0xffff88004c03dff0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549202]   Object 0xffff88004c03e000:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549213]   Object 0xffff88004c03e010:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549223]   Object 0xffff88004c03e020:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549234]   Object 0xffff88004c03e030:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549245]   Object 0xffff88004c03e040:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549256]   Object 0xffff88004c03e050:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549267]   Object 0xffff88004c03e060:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549277]   Object 0xffff88004c03e070:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549288]   Object 0xffff88004c03e080:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549299]   Object 0xffff88004c03e090:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549310]   Object 0xffff88004c03e0a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549321]   Object 0xffff88004c03e0b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549332]   Object 0xffff88004c03e0c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549342]   Object 0xffff88004c03e0d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549353]   Object 0xffff88004c03e0e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549364]   Object 0xffff88004c03e0f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549375]   Object 0xffff88004c03e100:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549386]   Object 0xffff88004c03e110:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549397]   Object 0xffff88004c03e120:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549408]   Object 0xffff88004c03e130:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549418]   Object 0xffff88004c03e140:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549429]   Object 0xffff88004c03e150:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549440]   Object 0xffff88004c03e160:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549451]   Object 0xffff88004c03e170:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549462]   Object 0xffff88004c03e180:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549473]   Object 0xffff88004c03e190:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549483]   Object 0xffff88004c03e1a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549494]   Object 0xffff88004c03e1b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549505]   Object 0xffff88004c03e1c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549516]   Object 0xffff88004c03e1d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:42 srv64 kernel: [256747.549527]   Object 0xffff88004c03e1e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:32:42 srv64 kernel: [256747.549538]  Redzone 0xffff88004c03e1f0:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:32:42 srv64 kernel: [256747.549548]  Padding 0xffff88004c03e230:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:32:42 srv64 kernel: [256747.549560] Pid: 6475, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:32:42 srv64 kernel: [256747.549561] Call Trace:
Feb 14 10:32:42 srv64 kernel: [256747.549566]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:32:42 srv64 kernel: [256747.549569]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:32:42 srv64 kernel: [256747.549572]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:32:42 srv64 kernel: [256747.549575]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:32:42 srv64 kernel: [256747.549578]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:32:42 srv64 kernel: [256747.549581]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:32:42 srv64 kernel: [256747.549584]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:32:42 srv64 kernel: [256747.549588]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:32:42 srv64 kernel: [256747.549591]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:32:42 srv64 kernel: [256747.549593]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:32:42 srv64 kernel: [256747.549597]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:32:42 srv64 kernel: [256747.549600] FIX kmalloc-512: Restoring 0xffff88004c03e1f0-0xffff88004c03e1f7=0xcc
Feb 14 10:32:42 srv64 kernel: [256747.549601] 
Feb 14 10:32:52 srv64 kernel: [256758.170915] =============================================================================
Feb 14 10:32:52 srv64 kernel: [256758.170919] BUG kmalloc-512: Redzone overwritten
Feb 14 10:32:52 srv64 kernel: [256758.170921] -----------------------------------------------------------------------------
Feb 14 10:32:52 srv64 kernel: [256758.170922] 
Feb 14 10:32:52 srv64 kernel: [256758.170925] INFO: 0xffff88004c03e438-0xffff88004c03e43f. First byte 0xbb instead of 0xcc
Feb 14 10:32:52 srv64 kernel: [256758.170932] INFO: Allocated in alloc_skb+0x13/0x15 age=113819568 cpu=0 pid=0
Feb 14 10:32:52 srv64 kernel: [256758.170935] INFO: Freed in skb_release_data+0xb0/0xb5 age=113804253 cpu=0 pid=11022
Feb 14 10:32:52 srv64 kernel: [256758.170938] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:32:52 srv64 kernel: [256758.170940] INFO: Object 0xffff88004c03e238 @offset=8760 fp=0xffff88004c03c920
Feb 14 10:32:52 srv64 kernel: [256758.170941] 
Feb 14 10:32:52 srv64 kernel: [256758.170943] Bytes b4 0xffff88004c03e228:  56 c2 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a V�......ZZZZZZZZ
Feb 14 10:32:52 srv64 kernel: [256758.170954]   Object 0xffff88004c03e238:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.170965]   Object 0xffff88004c03e248:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.170976]   Object 0xffff88004c03e258:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.170987]   Object 0xffff88004c03e268:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.170997]   Object 0xffff88004c03e278:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171008]   Object 0xffff88004c03e288:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171019]   Object 0xffff88004c03e298:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171030]   Object 0xffff88004c03e2a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171040]   Object 0xffff88004c03e2b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171051]   Object 0xffff88004c03e2c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171062]   Object 0xffff88004c03e2d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171073]   Object 0xffff88004c03e2e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171083]   Object 0xffff88004c03e2f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171094]   Object 0xffff88004c03e308:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171105]   Object 0xffff88004c03e318:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171116]   Object 0xffff88004c03e328:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171126]   Object 0xffff88004c03e338:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171137]   Object 0xffff88004c03e348:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171148]   Object 0xffff88004c03e358:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171159]   Object 0xffff88004c03e368:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171170]   Object 0xffff88004c03e378:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171180]   Object 0xffff88004c03e388:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171191]   Object 0xffff88004c03e398:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171202]   Object 0xffff88004c03e3a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171213]   Object 0xffff88004c03e3b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171223]   Object 0xffff88004c03e3c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171234]   Object 0xffff88004c03e3d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171245]   Object 0xffff88004c03e3e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171256]   Object 0xffff88004c03e3f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171266]   Object 0xffff88004c03e408:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171277]   Object 0xffff88004c03e418:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:32:52 srv64 kernel: [256758.171288]   Object 0xffff88004c03e428:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:32:52 srv64 kernel: [256758.171299]  Redzone 0xffff88004c03e438:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:32:52 srv64 kernel: [256758.171309]  Padding 0xffff88004c03e478:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:32:52 srv64 kernel: [256758.171321] Pid: 6482, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:32:52 srv64 kernel: [256758.171322] Call Trace:
Feb 14 10:32:52 srv64 kernel: [256758.171327]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:32:52 srv64 kernel: [256758.171330]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:32:52 srv64 kernel: [256758.171333]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:32:52 srv64 kernel: [256758.171336]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:32:52 srv64 kernel: [256758.171339]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:32:52 srv64 kernel: [256758.171342]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:32:52 srv64 kernel: [256758.171345]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:32:52 srv64 kernel: [256758.171349]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:32:52 srv64 kernel: [256758.171351]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:32:52 srv64 kernel: [256758.171354]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:32:52 srv64 kernel: [256758.171357]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:32:52 srv64 kernel: [256758.171360] FIX kmalloc-512: Restoring 0xffff88004c03e438-0xffff88004c03e43f=0xcc
Feb 14 10:32:52 srv64 kernel: [256758.171361] 
Feb 14 10:33:05 srv64 kernel: [256770.920890] =============================================================================
Feb 14 10:33:05 srv64 kernel: [256770.920894] BUG kmalloc-512: Redzone overwritten
Feb 14 10:33:05 srv64 kernel: [256770.920896] -----------------------------------------------------------------------------
Feb 14 10:33:05 srv64 kernel: [256770.920897] 
Feb 14 10:33:05 srv64 kernel: [256770.920900] INFO: 0xffff88004c03e680-0xffff88004c03e687. First byte 0xbb instead of 0xcc
Feb 14 10:33:05 srv64 kernel: [256770.920907] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113835178 cpu=0 pid=0
Feb 14 10:33:05 srv64 kernel: [256770.920910] INFO: Freed in skb_release_data+0xb0/0xb5 age=113821946 cpu=1 pid=11022
Feb 14 10:33:05 srv64 kernel: [256770.920913] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:33:05 srv64 kernel: [256770.920915] INFO: Object 0xffff88004c03e480 @offset=9344 fp=0xffff88004c03eda0
Feb 14 10:33:05 srv64 kernel: [256770.920916] 
Feb 14 10:33:05 srv64 kernel: [256770.920918] Bytes b4 0xffff88004c03e470:  dd b9 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a ݹ......ZZZZZZZZ
Feb 14 10:33:05 srv64 kernel: [256770.920929]   Object 0xffff88004c03e480:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.920940]   Object 0xffff88004c03e490:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.920951]   Object 0xffff88004c03e4a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.920962]   Object 0xffff88004c03e4b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.920973]   Object 0xffff88004c03e4c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.920983]   Object 0xffff88004c03e4d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.920994]   Object 0xffff88004c03e4e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921005]   Object 0xffff88004c03e4f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921016]   Object 0xffff88004c03e500:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921027]   Object 0xffff88004c03e510:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921038]   Object 0xffff88004c03e520:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921049]   Object 0xffff88004c03e530:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921059]   Object 0xffff88004c03e540:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921070]   Object 0xffff88004c03e550:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921081]   Object 0xffff88004c03e560:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921091]   Object 0xffff88004c03e570:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921102]   Object 0xffff88004c03e580:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921113]   Object 0xffff88004c03e590:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921123]   Object 0xffff88004c03e5a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921134]   Object 0xffff88004c03e5b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921145]   Object 0xffff88004c03e5c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921155]   Object 0xffff88004c03e5d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921166]   Object 0xffff88004c03e5e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921177]   Object 0xffff88004c03e5f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921187]   Object 0xffff88004c03e600:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921198]   Object 0xffff88004c03e610:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921208]   Object 0xffff88004c03e620:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921219]   Object 0xffff88004c03e630:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921230]   Object 0xffff88004c03e640:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921240]   Object 0xffff88004c03e650:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921251]   Object 0xffff88004c03e660:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:05 srv64 kernel: [256770.921261]   Object 0xffff88004c03e670:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:33:05 srv64 kernel: [256770.921272]  Redzone 0xffff88004c03e680:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:33:05 srv64 kernel: [256770.921282]  Padding 0xffff88004c03e6c0:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:33:05 srv64 kernel: [256770.921294] Pid: 6483, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:33:05 srv64 kernel: [256770.921295] Call Trace:
Feb 14 10:33:05 srv64 kernel: [256770.921301]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:33:05 srv64 kernel: [256770.921303]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:33:05 srv64 kernel: [256770.921306]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:33:05 srv64 kernel: [256770.921309]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:33:05 srv64 kernel: [256770.921312]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:33:05 srv64 kernel: [256770.921315]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:33:05 srv64 kernel: [256770.921318]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:33:05 srv64 kernel: [256770.921322]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:33:05 srv64 kernel: [256770.921325]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:33:05 srv64 kernel: [256770.921327]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:33:05 srv64 kernel: [256770.921331]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:33:05 srv64 kernel: [256770.921334] FIX kmalloc-512: Restoring 0xffff88004c03e680-0xffff88004c03e687=0xcc
Feb 14 10:33:05 srv64 kernel: [256770.921335] 
Feb 14 10:33:18 srv64 kernel: [256783.488842] =============================================================================
Feb 14 10:33:18 srv64 kernel: [256783.488846] BUG kmalloc-512: Redzone overwritten
Feb 14 10:33:18 srv64 kernel: [256783.488848] -----------------------------------------------------------------------------
Feb 14 10:33:18 srv64 kernel: [256783.488849] 
Feb 14 10:33:18 srv64 kernel: [256783.488851] INFO: 0xffff88004c03e8c8-0xffff88004c03e8cf. First byte 0xbb instead of 0xcc
Feb 14 10:33:18 srv64 kernel: [256783.488859] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113845743 cpu=0 pid=0
Feb 14 10:33:18 srv64 kernel: [256783.488862] INFO: Freed in skb_release_data+0xb0/0xb5 age=113830273 cpu=1 pid=11022
Feb 14 10:33:18 srv64 kernel: [256783.488865] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:33:18 srv64 kernel: [256783.488867] INFO: Object 0xffff88004c03e6c8 @offset=9928 fp=0xffff88004c03cdb0
Feb 14 10:33:18 srv64 kernel: [256783.488868] 
Feb 14 10:33:18 srv64 kernel: [256783.488870] Bytes b4 0xffff88004c03e6b8:  8e a6 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a .�......ZZZZZZZZ
Feb 14 10:33:18 srv64 kernel: [256783.488881]   Object 0xffff88004c03e6c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.488892]   Object 0xffff88004c03e6d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.488903]   Object 0xffff88004c03e6e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.488914]   Object 0xffff88004c03e6f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.488925]   Object 0xffff88004c03e708:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.488935]   Object 0xffff88004c03e718:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.488946]   Object 0xffff88004c03e728:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.488957]   Object 0xffff88004c03e738:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.488968]   Object 0xffff88004c03e748:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.488979]   Object 0xffff88004c03e758:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.488989]   Object 0xffff88004c03e768:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489000]   Object 0xffff88004c03e778:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489011]   Object 0xffff88004c03e788:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489022]   Object 0xffff88004c03e798:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489033]   Object 0xffff88004c03e7a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489043]   Object 0xffff88004c03e7b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489054]   Object 0xffff88004c03e7c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489065]   Object 0xffff88004c03e7d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489076]   Object 0xffff88004c03e7e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489087]   Object 0xffff88004c03e7f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489098]   Object 0xffff88004c03e808:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489108]   Object 0xffff88004c03e818:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489119]   Object 0xffff88004c03e828:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489130]   Object 0xffff88004c03e838:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489141]   Object 0xffff88004c03e848:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489152]   Object 0xffff88004c03e858:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489162]   Object 0xffff88004c03e868:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489173]   Object 0xffff88004c03e878:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489184]   Object 0xffff88004c03e888:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489195]   Object 0xffff88004c03e898:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489206]   Object 0xffff88004c03e8a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:18 srv64 kernel: [256783.489217]   Object 0xffff88004c03e8b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:33:18 srv64 kernel: [256783.489228]  Redzone 0xffff88004c03e8c8:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:33:18 srv64 kernel: [256783.489238]  Padding 0xffff88004c03e908:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:33:18 srv64 kernel: [256783.489249] Pid: 6484, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:33:18 srv64 kernel: [256783.489251] Call Trace:
Feb 14 10:33:18 srv64 kernel: [256783.489256]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:33:18 srv64 kernel: [256783.489259]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:33:18 srv64 kernel: [256783.489262]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:33:18 srv64 kernel: [256783.489265]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:33:18 srv64 kernel: [256783.489268]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:33:18 srv64 kernel: [256783.489270]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:33:18 srv64 kernel: [256783.489274]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:33:18 srv64 kernel: [256783.489278]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:33:18 srv64 kernel: [256783.489280]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:33:18 srv64 kernel: [256783.489283]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:33:18 srv64 kernel: [256783.489286]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:33:18 srv64 kernel: [256783.489289] FIX kmalloc-512: Restoring 0xffff88004c03e8c8-0xffff88004c03e8cf=0xcc
Feb 14 10:33:18 srv64 kernel: [256783.489290] 
Feb 14 10:33:29 srv64 kernel: [256795.064848] =============================================================================
Feb 14 10:33:29 srv64 kernel: [256795.064852] BUG kmalloc-512: Redzone overwritten
Feb 14 10:33:29 srv64 kernel: [256795.064854] -----------------------------------------------------------------------------
Feb 14 10:33:29 srv64 kernel: [256795.064855] 
Feb 14 10:33:29 srv64 kernel: [256795.064857] INFO: 0xffff88004c03eb10-0xffff88004c03eb17. First byte 0xbb instead of 0xcc
Feb 14 10:33:29 srv64 kernel: [256795.064864] INFO: Allocated in sock_alloc_send_pskb+0xc0/0x2dd age=113854438 cpu=0 pid=2692
Feb 14 10:33:29 srv64 kernel: [256795.064868] INFO: Freed in skb_release_data+0xb0/0xb5 age=113854438 cpu=1 pid=1870
Feb 14 10:33:29 srv64 kernel: [256795.064870] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03cff8 flags=0x20000000004081
Feb 14 10:33:29 srv64 kernel: [256795.064873] INFO: Object 0xffff88004c03e910 @offset=10512 fp=0x          (null)
Feb 14 10:33:29 srv64 kernel: [256795.064874] 
Feb 14 10:33:29 srv64 kernel: [256795.064876] Bytes b4 0xffff88004c03e900:  1f b7 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a .�......ZZZZZZZZ
Feb 14 10:33:29 srv64 kernel: [256795.064887]   Object 0xffff88004c03e910:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.064897]   Object 0xffff88004c03e920:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.064908]   Object 0xffff88004c03e930:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.064919]   Object 0xffff88004c03e940:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.064930]   Object 0xffff88004c03e950:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.064941]   Object 0xffff88004c03e960:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.064951]   Object 0xffff88004c03e970:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.064962]   Object 0xffff88004c03e980:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.064973]   Object 0xffff88004c03e990:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.064984]   Object 0xffff88004c03e9a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.064994]   Object 0xffff88004c03e9b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065005]   Object 0xffff88004c03e9c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065016]   Object 0xffff88004c03e9d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065027]   Object 0xffff88004c03e9e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065038]   Object 0xffff88004c03e9f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065048]   Object 0xffff88004c03ea00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065059]   Object 0xffff88004c03ea10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065070]   Object 0xffff88004c03ea20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065080]   Object 0xffff88004c03ea30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065091]   Object 0xffff88004c03ea40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065102]   Object 0xffff88004c03ea50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065112]   Object 0xffff88004c03ea60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065123]   Object 0xffff88004c03ea70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065134]   Object 0xffff88004c03ea80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065145]   Object 0xffff88004c03ea90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065155]   Object 0xffff88004c03eaa0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065166]   Object 0xffff88004c03eab0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065177]   Object 0xffff88004c03eac0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065188]   Object 0xffff88004c03ead0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065199]   Object 0xffff88004c03eae0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065209]   Object 0xffff88004c03eaf0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:29 srv64 kernel: [256795.065220]   Object 0xffff88004c03eb00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:33:29 srv64 kernel: [256795.065231]  Redzone 0xffff88004c03eb10:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:33:29 srv64 kernel: [256795.065241]  Padding 0xffff88004c03eb50:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:33:29 srv64 kernel: [256795.065253] Pid: 6485, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:33:29 srv64 kernel: [256795.065254] Call Trace:
Feb 14 10:33:29 srv64 kernel: [256795.065260]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:33:29 srv64 kernel: [256795.065263]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:33:29 srv64 kernel: [256795.065265]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:33:29 srv64 kernel: [256795.065268]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:33:29 srv64 kernel: [256795.065271]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:33:29 srv64 kernel: [256795.065274]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:33:29 srv64 kernel: [256795.065277]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:33:29 srv64 kernel: [256795.065281]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:33:29 srv64 kernel: [256795.065284]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:33:29 srv64 kernel: [256795.065286]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:33:29 srv64 kernel: [256795.065290]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:33:29 srv64 kernel: [256795.065293] FIX kmalloc-512: Restoring 0xffff88004c03eb10-0xffff88004c03eb17=0xcc
Feb 14 10:33:29 srv64 kernel: [256795.065294] 
Feb 14 10:33:41 srv64 kernel: [256806.621986] =============================================================================
Feb 14 10:33:41 srv64 kernel: [256806.621991] BUG kmalloc-512: Redzone overwritten
Feb 14 10:33:41 srv64 kernel: [256806.621992] -----------------------------------------------------------------------------
Feb 14 10:33:41 srv64 kernel: [256806.621993] 
Feb 14 10:33:41 srv64 kernel: [256806.621996] INFO: 0xffff88004c03ed58-0xffff88004c03ed5f. First byte 0xbb instead of 0xcc
Feb 14 10:33:41 srv64 kernel: [256806.622003] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113867461 cpu=0 pid=0
Feb 14 10:33:41 srv64 kernel: [256806.622007] INFO: Freed in skb_release_data+0xb0/0xb5 age=113850536 cpu=1 pid=11022
Feb 14 10:33:41 srv64 kernel: [256806.622009] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03cff8 flags=0x20000000004081
Feb 14 10:33:41 srv64 kernel: [256806.622012] INFO: Object 0xffff88004c03eb58 @offset=11096 fp=0xffff88004c03e238
Feb 14 10:33:41 srv64 kernel: [256806.622013] 
Feb 14 10:33:41 srv64 kernel: [256806.622015] Bytes b4 0xffff88004c03eb48:  f2 85 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a �.......ZZZZZZZZ
Feb 14 10:33:41 srv64 kernel: [256806.622026]   Object 0xffff88004c03eb58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622037]   Object 0xffff88004c03eb68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622048]   Object 0xffff88004c03eb78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622059]   Object 0xffff88004c03eb88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622069]   Object 0xffff88004c03eb98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622080]   Object 0xffff88004c03eba8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622091]   Object 0xffff88004c03ebb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622102]   Object 0xffff88004c03ebc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622113]   Object 0xffff88004c03ebd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622124]   Object 0xffff88004c03ebe8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622135]   Object 0xffff88004c03ebf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622146]   Object 0xffff88004c03ec08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622157]   Object 0xffff88004c03ec18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622168]   Object 0xffff88004c03ec28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622179]   Object 0xffff88004c03ec38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622190]   Object 0xffff88004c03ec48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622201]   Object 0xffff88004c03ec58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622212]   Object 0xffff88004c03ec68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622223]   Object 0xffff88004c03ec78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622233]   Object 0xffff88004c03ec88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622244]   Object 0xffff88004c03ec98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622255]   Object 0xffff88004c03eca8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622266]   Object 0xffff88004c03ecb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622277]   Object 0xffff88004c03ecc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622288]   Object 0xffff88004c03ecd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622299]   Object 0xffff88004c03ece8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622310]   Object 0xffff88004c03ecf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622321]   Object 0xffff88004c03ed08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622332]   Object 0xffff88004c03ed18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622343]   Object 0xffff88004c03ed28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622353]   Object 0xffff88004c03ed38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:33:41 srv64 kernel: [256806.622364]   Object 0xffff88004c03ed48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:33:41 srv64 kernel: [256806.622375]  Redzone 0xffff88004c03ed58:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:33:41 srv64 kernel: [256806.622386]  Padding 0xffff88004c03ed98:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:33:41 srv64 kernel: [256806.622397] Pid: 6487, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:33:41 srv64 kernel: [256806.622399] Call Trace:
Feb 14 10:33:41 srv64 kernel: [256806.622404]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:33:41 srv64 kernel: [256806.622407]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:33:41 srv64 kernel: [256806.622410]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:33:41 srv64 kernel: [256806.622412]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:33:41 srv64 kernel: [256806.622415]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:33:41 srv64 kernel: [256806.622418]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:33:41 srv64 kernel: [256806.622422]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:33:41 srv64 kernel: [256806.622426]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:33:41 srv64 kernel: [256806.622428]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:33:41 srv64 kernel: [256806.622431]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:33:41 srv64 kernel: [256806.622434]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:33:41 srv64 kernel: [256806.622437] FIX kmalloc-512: Restoring 0xffff88004c03ed58-0xffff88004c03ed5f=0xcc
Feb 14 10:33:41 srv64 kernel: [256806.622438] 
Feb 14 10:34:00 srv64 kernel: [256825.983246] =============================================================================
Feb 14 10:34:00 srv64 kernel: [256825.983250] BUG kmalloc-512: Redzone overwritten
Feb 14 10:34:00 srv64 kernel: [256825.983252] -----------------------------------------------------------------------------
Feb 14 10:34:00 srv64 kernel: [256825.983253] 
Feb 14 10:34:00 srv64 kernel: [256825.983255] INFO: 0xffff88004c03efa0-0xffff88004c03efa7. First byte 0xbb instead of 0xcc
Feb 14 10:34:00 srv64 kernel: [256825.983263] INFO: Allocated in alloc_skb+0x13/0x15 age=113890711 cpu=0 pid=11023
Feb 14 10:34:00 srv64 kernel: [256825.983266] INFO: Freed in skb_release_data+0xb0/0xb5 age=113877009 cpu=1 pid=11022
Feb 14 10:34:00 srv64 kernel: [256825.983268] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03f478 flags=0x20000000004081
Feb 14 10:34:00 srv64 kernel: [256825.983271] INFO: Object 0xffff88004c03eda0 @offset=11680 fp=0xffff88004c03f230
Feb 14 10:34:00 srv64 kernel: [256825.983272] 
Feb 14 10:34:00 srv64 kernel: [256825.983274] Bytes b4 0xffff88004c03ed90:  56 c2 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a V�......ZZZZZZZZ
Feb 14 10:34:00 srv64 kernel: [256825.983285]   Object 0xffff88004c03eda0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983296]   Object 0xffff88004c03edb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983306]   Object 0xffff88004c03edc0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983317]   Object 0xffff88004c03edd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983328]   Object 0xffff88004c03ede0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983339]   Object 0xffff88004c03edf0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983350]   Object 0xffff88004c03ee00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983360]   Object 0xffff88004c03ee10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983371]   Object 0xffff88004c03ee20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983382]   Object 0xffff88004c03ee30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983393]   Object 0xffff88004c03ee40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983404]   Object 0xffff88004c03ee50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983414]   Object 0xffff88004c03ee60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983425]   Object 0xffff88004c03ee70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983436]   Object 0xffff88004c03ee80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983447]   Object 0xffff88004c03ee90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983458]   Object 0xffff88004c03eea0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983468]   Object 0xffff88004c03eeb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983479]   Object 0xffff88004c03eec0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983490]   Object 0xffff88004c03eed0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983501]   Object 0xffff88004c03eee0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983512]   Object 0xffff88004c03eef0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983523]   Object 0xffff88004c03ef00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983533]   Object 0xffff88004c03ef10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983544]   Object 0xffff88004c03ef20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983555]   Object 0xffff88004c03ef30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983566]   Object 0xffff88004c03ef40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983577]   Object 0xffff88004c03ef50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983588]   Object 0xffff88004c03ef60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983598]   Object 0xffff88004c03ef70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983609]   Object 0xffff88004c03ef80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:00 srv64 kernel: [256825.983620]   Object 0xffff88004c03ef90:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:34:00 srv64 kernel: [256825.983631]  Redzone 0xffff88004c03efa0:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:34:00 srv64 kernel: [256825.983641]  Padding 0xffff88004c03efe0:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:34:00 srv64 kernel: [256825.983653] Pid: 6494, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:34:00 srv64 kernel: [256825.983655] Call Trace:
Feb 14 10:34:00 srv64 kernel: [256825.983659]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:34:00 srv64 kernel: [256825.983662]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:34:00 srv64 kernel: [256825.983665]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:34:00 srv64 kernel: [256825.983668]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:34:00 srv64 kernel: [256825.983671]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:34:00 srv64 kernel: [256825.983674]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:34:00 srv64 kernel: [256825.983677]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:34:00 srv64 kernel: [256825.983681]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:34:00 srv64 kernel: [256825.983684]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:34:00 srv64 kernel: [256825.983686]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:34:00 srv64 kernel: [256825.983690]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:34:00 srv64 kernel: [256825.983692] FIX kmalloc-512: Restoring 0xffff88004c03efa0-0xffff88004c03efa7=0xcc
Feb 14 10:34:00 srv64 kernel: [256825.983693] 
Feb 14 10:34:00 srv64 kernel: [256826.002002] SLUB selinux_inode_security: Skipped busy slab 0xffffea00023f7db8
Feb 14 10:34:13 srv64 kernel: [256838.890020] =============================================================================
Feb 14 10:34:13 srv64 kernel: [256838.890025] BUG kmalloc-512: Redzone overwritten
Feb 14 10:34:13 srv64 kernel: [256838.890027] -----------------------------------------------------------------------------
Feb 14 10:34:13 srv64 kernel: [256838.890028] 
Feb 14 10:34:13 srv64 kernel: [256838.890030] INFO: 0xffff88004c03f1e8-0xffff88004c03f1ef. First byte 0xbb instead of 0xcc
Feb 14 10:34:13 srv64 kernel: [256838.890037] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113902490 cpu=0 pid=0
Feb 14 10:34:13 srv64 kernel: [256838.890041] INFO: Freed in skb_release_data+0xb0/0xb5 age=113887742 cpu=1 pid=11022
Feb 14 10:34:13 srv64 kernel: [256838.890043] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03f478 flags=0x20000000004081
Feb 14 10:34:13 srv64 kernel: [256838.890046] INFO: Object 0xffff88004c03efe8 @offset=12264 fp=0xffff88004c03db60
Feb 14 10:34:13 srv64 kernel: [256838.890047] 
Feb 14 10:34:13 srv64 kernel: [256838.890048] Bytes b4 0xffff88004c03efd8:  8e a6 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a .�......ZZZZZZZZ
Feb 14 10:34:13 srv64 kernel: [256838.890060]   Object 0xffff88004c03efe8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890071]   Object 0xffff88004c03eff8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890082]   Object 0xffff88004c03f008:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890092]   Object 0xffff88004c03f018:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890103]   Object 0xffff88004c03f028:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890114]   Object 0xffff88004c03f038:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890125]   Object 0xffff88004c03f048:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890136]   Object 0xffff88004c03f058:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890147]   Object 0xffff88004c03f068:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890158]   Object 0xffff88004c03f078:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890169]   Object 0xffff88004c03f088:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890179]   Object 0xffff88004c03f098:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890190]   Object 0xffff88004c03f0a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890201]   Object 0xffff88004c03f0b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890212]   Object 0xffff88004c03f0c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890223]   Object 0xffff88004c03f0d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890234]   Object 0xffff88004c03f0e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890245]   Object 0xffff88004c03f0f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890256]   Object 0xffff88004c03f108:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890266]   Object 0xffff88004c03f118:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890277]   Object 0xffff88004c03f128:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890288]   Object 0xffff88004c03f138:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890299]   Object 0xffff88004c03f148:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890310]   Object 0xffff88004c03f158:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890321]   Object 0xffff88004c03f168:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890331]   Object 0xffff88004c03f178:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890342]   Object 0xffff88004c03f188:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890353]   Object 0xffff88004c03f198:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890364]   Object 0xffff88004c03f1a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890375]   Object 0xffff88004c03f1b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890386]   Object 0xffff88004c03f1c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:13 srv64 kernel: [256838.890396]   Object 0xffff88004c03f1d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:34:13 srv64 kernel: [256838.890407]  Redzone 0xffff88004c03f1e8:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:34:13 srv64 kernel: [256838.890418]  Padding 0xffff88004c03f228:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:34:13 srv64 kernel: [256838.890429] Pid: 6495, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:34:13 srv64 kernel: [256838.890431] Call Trace:
Feb 14 10:34:13 srv64 kernel: [256838.890436]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:34:13 srv64 kernel: [256838.890439]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:34:13 srv64 kernel: [256838.890442]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:34:13 srv64 kernel: [256838.890444]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:34:13 srv64 kernel: [256838.890447]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:34:13 srv64 kernel: [256838.890450]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:34:13 srv64 kernel: [256838.890454]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:34:13 srv64 kernel: [256838.890458]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:34:13 srv64 kernel: [256838.890460]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:34:13 srv64 kernel: [256838.890463]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:34:13 srv64 kernel: [256838.890466]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:34:13 srv64 kernel: [256838.890469] FIX kmalloc-512: Restoring 0xffff88004c03f1e8-0xffff88004c03f1ef=0xcc
Feb 14 10:34:13 srv64 kernel: [256838.890470] 
Feb 14 10:34:24 srv64 kernel: [256849.765297] =============================================================================
Feb 14 10:34:24 srv64 kernel: [256849.765301] BUG kmalloc-512: Redzone overwritten
Feb 14 10:34:24 srv64 kernel: [256849.765303] -----------------------------------------------------------------------------
Feb 14 10:34:24 srv64 kernel: [256849.765304] 
Feb 14 10:34:24 srv64 kernel: [256849.765306] INFO: 0xffff88004c03f430-0xffff88004c03f437. First byte 0xbb instead of 0xcc
Feb 14 10:34:24 srv64 kernel: [256849.765313] INFO: Allocated in __netdev_alloc_skb+0x22/0x3f age=113914493 cpu=0 pid=11023
Feb 14 10:34:24 srv64 kernel: [256849.765317] INFO: Freed in skb_release_data+0xb0/0xb5 age=113900791 cpu=1 pid=11022
Feb 14 10:34:24 srv64 kernel: [256849.765319] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03f478 flags=0x20000000004081
Feb 14 10:34:24 srv64 kernel: [256849.765322] INFO: Object 0xffff88004c03f230 @offset=12848 fp=0xffff88004c03f908
Feb 14 10:34:24 srv64 kernel: [256849.765323] 
Feb 14 10:34:24 srv64 kernel: [256849.765324] Bytes b4 0xffff88004c03f220:  0c af 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a .�......ZZZZZZZZ
Feb 14 10:34:24 srv64 kernel: [256849.765336]   Object 0xffff88004c03f230:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765347]   Object 0xffff88004c03f240:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765357]   Object 0xffff88004c03f250:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765368]   Object 0xffff88004c03f260:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765379]   Object 0xffff88004c03f270:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765390]   Object 0xffff88004c03f280:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765401]   Object 0xffff88004c03f290:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765411]   Object 0xffff88004c03f2a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765422]   Object 0xffff88004c03f2b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765433]   Object 0xffff88004c03f2c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765444]   Object 0xffff88004c03f2d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765455]   Object 0xffff88004c03f2e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765465]   Object 0xffff88004c03f2f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765476]   Object 0xffff88004c03f300:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765487]   Object 0xffff88004c03f310:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765498]   Object 0xffff88004c03f320:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765509]   Object 0xffff88004c03f330:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765520]   Object 0xffff88004c03f340:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765530]   Object 0xffff88004c03f350:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765541]   Object 0xffff88004c03f360:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765552]   Object 0xffff88004c03f370:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765563]   Object 0xffff88004c03f380:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765574]   Object 0xffff88004c03f390:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765585]   Object 0xffff88004c03f3a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765595]   Object 0xffff88004c03f3b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765606]   Object 0xffff88004c03f3c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765617]   Object 0xffff88004c03f3d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765628]   Object 0xffff88004c03f3e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765639]   Object 0xffff88004c03f3f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765649]   Object 0xffff88004c03f400:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765660]   Object 0xffff88004c03f410:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:24 srv64 kernel: [256849.765671]   Object 0xffff88004c03f420:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:34:24 srv64 kernel: [256849.765682]  Redzone 0xffff88004c03f430:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:34:24 srv64 kernel: [256849.765692]  Padding 0xffff88004c03f470:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:34:24 srv64 kernel: [256849.765704] Pid: 6496, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:34:24 srv64 kernel: [256849.765705] Call Trace:
Feb 14 10:34:24 srv64 kernel: [256849.765711]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:34:24 srv64 kernel: [256849.765713]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:34:24 srv64 kernel: [256849.765716]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:34:24 srv64 kernel: [256849.765719]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:34:24 srv64 kernel: [256849.765722]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:34:24 srv64 kernel: [256849.765725]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:34:24 srv64 kernel: [256849.765728]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:34:24 srv64 kernel: [256849.765732]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:34:24 srv64 kernel: [256849.765735]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:34:24 srv64 kernel: [256849.765737]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:34:24 srv64 kernel: [256849.765741]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:34:24 srv64 kernel: [256849.765744] FIX kmalloc-512: Restoring 0xffff88004c03f430-0xffff88004c03f437=0xcc
Feb 14 10:34:24 srv64 kernel: [256849.765745] 
Feb 14 10:34:33 srv64 kernel: [256859.055793] =============================================================================
Feb 14 10:34:33 srv64 kernel: [256859.055798] BUG kmalloc-512: Redzone overwritten
Feb 14 10:34:33 srv64 kernel: [256859.055799] -----------------------------------------------------------------------------
Feb 14 10:34:33 srv64 kernel: [256859.055800] 
Feb 14 10:34:33 srv64 kernel: [256859.055803] INFO: 0xffff88004c03f8c0-0xffff88004c03f8c7. First byte 0xbb instead of 0xcc
Feb 14 10:34:33 srv64 kernel: [256859.055810] INFO: Allocated in alloc_skb+0x13/0x15 age=113919895 cpu=0 pid=0
Feb 14 10:34:33 srv64 kernel: [256859.055813] INFO: Freed in skb_release_data+0xb0/0xb5 age=113902969 cpu=1 pid=11022
Feb 14 10:34:33 srv64 kernel: [256859.055816] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:34:33 srv64 kernel: [256859.055818] INFO: Object 0xffff88004c03f6c0 @offset=14016 fp=0xffff88004c03eb58
Feb 14 10:34:33 srv64 kernel: [256859.055819] 
Feb 14 10:34:33 srv64 kernel: [256859.055821] Bytes b4 0xffff88004c03f6b0:  37 b0 4a 0f 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a 7�J.....ZZZZZZZZ
Feb 14 10:34:33 srv64 kernel: [256859.055832]   Object 0xffff88004c03f6c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055843]   Object 0xffff88004c03f6d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055854]   Object 0xffff88004c03f6e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055865]   Object 0xffff88004c03f6f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055875]   Object 0xffff88004c03f700:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055886]   Object 0xffff88004c03f710:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055897]   Object 0xffff88004c03f720:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055908]   Object 0xffff88004c03f730:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055919]   Object 0xffff88004c03f740:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055930]   Object 0xffff88004c03f750:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055941]   Object 0xffff88004c03f760:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055952]   Object 0xffff88004c03f770:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055963]   Object 0xffff88004c03f780:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055974]   Object 0xffff88004c03f790:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055985]   Object 0xffff88004c03f7a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.055996]   Object 0xffff88004c03f7b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056006]   Object 0xffff88004c03f7c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056017]   Object 0xffff88004c03f7d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056028]   Object 0xffff88004c03f7e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056038]   Object 0xffff88004c03f7f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056049]   Object 0xffff88004c03f800:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056060]   Object 0xffff88004c03f810:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056070]   Object 0xffff88004c03f820:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056081]   Object 0xffff88004c03f830:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056092]   Object 0xffff88004c03f840:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056102]   Object 0xffff88004c03f850:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056113]   Object 0xffff88004c03f860:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056124]   Object 0xffff88004c03f870:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056135]   Object 0xffff88004c03f880:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056146]   Object 0xffff88004c03f890:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056156]   Object 0xffff88004c03f8a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:33 srv64 kernel: [256859.056167]   Object 0xffff88004c03f8b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:34:33 srv64 kernel: [256859.056178]  Redzone 0xffff88004c03f8c0:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:34:33 srv64 kernel: [256859.056188]  Padding 0xffff88004c03f900:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:34:33 srv64 kernel: [256859.056200] Pid: 6502, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:34:33 srv64 kernel: [256859.056202] Call Trace:
Feb 14 10:34:33 srv64 kernel: [256859.056207]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:34:33 srv64 kernel: [256859.056209]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:34:33 srv64 kernel: [256859.056212]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:34:33 srv64 kernel: [256859.056215]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:34:33 srv64 kernel: [256859.056218]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:34:33 srv64 kernel: [256859.056221]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:34:33 srv64 kernel: [256859.056224]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:34:33 srv64 kernel: [256859.056228]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:34:33 srv64 kernel: [256859.056231]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:34:33 srv64 kernel: [256859.056233]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:34:33 srv64 kernel: [256859.056237]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:34:33 srv64 kernel: [256859.056239] FIX kmalloc-512: Restoring 0xffff88004c03f8c0-0xffff88004c03f8c7=0xcc
Feb 14 10:34:33 srv64 kernel: [256859.056240] 
Feb 14 10:34:56 srv64 kernel: [256882.050665] =============================================================================
Feb 14 10:34:56 srv64 kernel: [256882.050670] BUG kmalloc-512: Redzone overwritten
Feb 14 10:34:56 srv64 kernel: [256882.050671] -----------------------------------------------------------------------------
Feb 14 10:34:56 srv64 kernel: [256882.050672] 
Feb 14 10:34:56 srv64 kernel: [256882.050675] INFO: 0xffff88004c03fb08-0xffff88004c03fb0f. First byte 0xbb instead of 0xcc
Feb 14 10:34:56 srv64 kernel: [256882.050682] INFO: Allocated in alloc_skb+0x13/0x15 age=113947248 cpu=0 pid=0
Feb 14 10:34:56 srv64 kernel: [256882.050685] INFO: Freed in skb_release_data+0xb0/0xb5 age=113934507 cpu=1 pid=11022
Feb 14 10:34:56 srv64 kernel: [256882.050688] INFO: Slab 0xffffea00010a0d20 objects=28 used=24 fp=0xffff88004c03fd98 flags=0x20000000004081
Feb 14 10:34:56 srv64 kernel: [256882.050690] INFO: Object 0xffff88004c03f908 @offset=14600 fp=0xffff88004c03cb68
Feb 14 10:34:56 srv64 kernel: [256882.050691] 
Feb 14 10:34:56 srv64 kernel: [256882.050693] Bytes b4 0xffff88004c03f8f8:  56 c2 80 08 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a V�......ZZZZZZZZ
Feb 14 10:34:56 srv64 kernel: [256882.050704]   Object 0xffff88004c03f908:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050715]   Object 0xffff88004c03f918:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050726]   Object 0xffff88004c03f928:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050737]   Object 0xffff88004c03f938:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050748]   Object 0xffff88004c03f948:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050758]   Object 0xffff88004c03f958:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050769]   Object 0xffff88004c03f968:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050780]   Object 0xffff88004c03f978:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050791]   Object 0xffff88004c03f988:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050802]   Object 0xffff88004c03f998:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050813]   Object 0xffff88004c03f9a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050823]   Object 0xffff88004c03f9b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050834]   Object 0xffff88004c03f9c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050845]   Object 0xffff88004c03f9d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050856]   Object 0xffff88004c03f9e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050866]   Object 0xffff88004c03f9f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050877]   Object 0xffff88004c03fa08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050888]   Object 0xffff88004c03fa18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050899]   Object 0xffff88004c03fa28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050909]   Object 0xffff88004c03fa38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050920]   Object 0xffff88004c03fa48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050931]   Object 0xffff88004c03fa58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050942]   Object 0xffff88004c03fa68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050953]   Object 0xffff88004c03fa78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050963]   Object 0xffff88004c03fa88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050974]   Object 0xffff88004c03fa98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050985]   Object 0xffff88004c03faa8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.050995]   Object 0xffff88004c03fab8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.051006]   Object 0xffff88004c03fac8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.051017]   Object 0xffff88004c03fad8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.051028]   Object 0xffff88004c03fae8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
Feb 14 10:34:56 srv64 kernel: [256882.051038]   Object 0xffff88004c03faf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk�
Feb 14 10:34:56 srv64 kernel: [256882.051049]  Redzone 0xffff88004c03fb08:  bb bb bb bb bb bb bb bb                         ��������        
Feb 14 10:34:56 srv64 kernel: [256882.051060]  Padding 0xffff88004c03fb48:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ        
Feb 14 10:34:56 srv64 kernel: [256882.051071] Pid: 6509, comm: slabinfo Not tainted 2.6.38-rc4 #7
Feb 14 10:34:56 srv64 kernel: [256882.051073] Call Trace:
Feb 14 10:34:56 srv64 kernel: [256882.051078]  [<ffffffff81111d4a>] ? print_trailer+0x133/0x13c
Feb 14 10:34:56 srv64 kernel: [256882.051081]  [<ffffffff8111204d>] ? check_bytes_and_report+0xc1/0xff
Feb 14 10:34:56 srv64 kernel: [256882.051084]  [<ffffffff81112b67>] ? check_object+0x53/0x1b0
Feb 14 10:34:56 srv64 kernel: [256882.051087]  [<ffffffff81113a1f>] ? validate_slab_slab+0x105/0x154
Feb 14 10:34:56 srv64 kernel: [256882.051090]  [<ffffffff811151ce>] ? validate_store+0xbe/0x1c0
Feb 14 10:34:56 srv64 kernel: [256882.051092]  [<ffffffff81111300>] ? slab_attr_store+0x29/0x2d
Feb 14 10:34:56 srv64 kernel: [256882.051096]  [<ffffffff8118010c>] ? sysfs_write_file+0x107/0x143
Feb 14 10:34:56 srv64 kernel: [256882.051100]  [<ffffffff81124f6c>] ? vfs_write+0xac/0xff
Feb 14 10:34:56 srv64 kernel: [256882.051102]  [<ffffffff811261ca>] ? fget_light+0x42/0x89
Feb 14 10:34:56 srv64 kernel: [256882.051105]  [<ffffffff81125173>] ? sys_write+0x4a/0x6e
Feb 14 10:34:56 srv64 kernel: [256882.051108]  [<ffffffff8100ac82>] ? system_call_fastpath+0x16/0x1b
Feb 14 10:34:56 srv64 kernel: [256882.051111] FIX kmalloc-512: Restoring 0xffff88004c03fb08-0xffff88004c03fb0f=0xcc
Feb 14 10:34:56 srv64 kernel: [256882.051112] 


--------------000002050305070805020106--
