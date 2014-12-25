From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: NULL pointer dereference at skb_queue_tail()
Date: Thu, 25 Dec 2014 22:22:48 +0900
Message-ID: <201412252222.HIF57826.OQFSVFFOMHLOJt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:46699 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbaLYNWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2014 08:22:51 -0500
Received: from fsav402.sakura.ne.jp (fsav402.sakura.ne.jp [133.242.250.101])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sBPDMnh2057662
	for <netdev@vger.kernel.org>; Thu, 25 Dec 2014 22:22:49 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (KD175108057186.ppp-bb.dion.ne.jp [175.108.57.186])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sBPDMnn0057658
	for <netdev@vger.kernel.org>; Thu, 25 Dec 2014 22:22:49 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I can reproduce below oops when testing Linux 3.18 with memory allocation
failure injection module at https://lkml.org/lkml/2014/12/25/64 .

Looks similar to http://oops.kernel.org/oops/bug-unable-to-handle-kernel-null-pointer-dereference-at-skb_queue_tail/ .
Where should I check?

----------
[  273.709905] BUG: unable to handle kernel NULL pointer dereference at           (null)
[  273.713845] IP: [<ffffffff81535e27>] skb_queue_tail+0x37/0x60
[  273.716720] PGD 7887d067 PUD 7bc5b067 PMD 0 
[  273.718647] Oops: 0002 [#1] SMP 
[  273.719508] Modules linked in: fault_injection(OE) ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul crc32_pclmul dm_mirror crc32c_intel dm_region_hash ghash_clmulni_intel dm_log aesni_intel glue_helper dm_mod lrw gf128mul ablk_helper cryptd vmw_balloon ppdev microcode parport_pc serio_raw pcspkr vmw_vmci parport i2c_piix4 shpchp nfsd auth_rpcgss nfs_acl lockd grace sunrpc uinput sd_mod ata_generic pata_acpi vmwgfx drm_kms_helper ttm drm mptspi e1000 scsi_transport_spi mptscsih mptba
 se ata_piix libata i2c_core floppy [last unloaded: fault_injection]
[  273.739290] CPU: 2 PID: 2866 Comm: Xorg Tainted: G        W  OE  3.18.0+ #337
[  273.741001] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  273.743534] task: ffff880079f18000 ti: ffff88007a894000 task.ti: ffff88007a894000
[  273.745288] RIP: 0010:[<ffffffff81535e27>]  [<ffffffff81535e27>] skb_queue_tail+0x37/0x60
[  273.747275] RSP: 0018:ffff88007a897c18  EFLAGS: 00010046
[  273.748535] RAX: 0000000000000296 RBX: ffff8800360c0b10 RCX: 0000000000000000
[  273.750216] RDX: 0000000000000000 RSI: 0000000000000296 RDI: ffff8800360c0b24
[  273.751921] RBP: ffff88007a897c38 R08: 0000000000000296 R09: 0000000000000300
[  273.753624] R10: ffff88007f803600 R11: ffff88007a9dbd00 R12: ffff8800360c0b10
[  273.755336] R13: ffff8800360c0b24 R14: 0000000000000000 R15: 0000000000000000
[  273.757046] FS:  00007f512a6b0980(0000) GS:ffff88007fc80000(0000) knlGS:0000000000000000
[  273.758940] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  273.760295] CR2: 0000000000000000 CR3: 000000007bf4f000 CR4: 00000000000407e0
[  273.762047] Stack:
[  273.762541]  0000000000000020 ffff8800360c0b10 0000000000000020 ffff8800360c0a80
[  273.764392]  ffff88007a897cf8 ffffffff815e9b11 ffff880048861498 ffff8800360c0b10
[  273.766256]  0000002000000296 ffff88007a897d08 0000000000000020 ffff8800360c0d78
[  273.768099] Call Trace:
[  273.768695]  [<ffffffff815e9b11>] unix_stream_sendmsg+0x1d1/0x420
[  273.770157]  [<ffffffff8152cf2a>] sock_aio_write+0xca/0xe0
[  273.771472]  [<ffffffff811af8bc>] do_sync_readv_writev+0x4c/0x80
[  273.772910]  [<ffffffff811b1255>] do_readv_writev+0x1e5/0x280
[  273.774277]  [<ffffffffa01656d5>] ? vmw_unlocked_ioctl+0x15/0x20 [vmwgfx]
[  273.775899]  [<ffffffff811c2f40>] ? do_vfs_ioctl+0x2e0/0x4c0
[  273.777254]  [<ffffffff811ccfa5>] ? __fget_light+0x25/0x70
[  273.778557]  [<ffffffff81100e84>] ? __audit_syscall_entry+0xb4/0x110
[  273.780056]  [<ffffffff811b1379>] vfs_writev+0x39/0x50
[  273.781492]  [<ffffffff811b14aa>] SyS_writev+0x4a/0xd0
[  273.782741]  [<ffffffff81647729>] system_call_fastpath+0x12/0x17
[  273.784192] Code: 8d 6f 14 41 54 49 89 f4 53 48 89 fb 4c 89 ef 48 83 ec 08 e8 ec 13 11 00 48 8b 53 08 49 89 1c 24 4c 89 ef 48 89 c6 49 89 54 24 08 <4c> 89 22 83 43 10 01 4c 89 63 08 e8 19 10 11 00 48 83 c4 08 5b 
[  273.790477] RIP  [<ffffffff81535e27>] skb_queue_tail+0x37/0x60
[  273.791954]  RSP <ffff88007a897c18>
[  273.792798] CR2: 0000000000000000
----------

----------
crash> bt -l
PID: 2866   TASK: ffff880079f18000  CPU: 2   COMMAND: "Xorg"
 #0 [ffff88007a8977f0] machine_kexec at ffffffff8104d092
    /root/linux/arch/x86/kernel/machine_kexec_64.c: 319
 #1 [ffff88007a897840] crash_kexec at ffffffff810ea6d3
    /root/linux/kernel/kexec.c: 1482
 #2 [ffff88007a897910] oops_end at ffffffff81016678
    /root/linux/arch/x86/kernel/dumpstack.c: 231
 #3 [ffff88007a897940] no_context at ffffffff8163bbc2
    /root/linux/arch/x86/mm/fault.c: 724
 #4 [ffff88007a8979a0] __bad_area_nosemaphore at ffffffff8163bc99
    /root/linux/arch/x86/mm/fault.c: 804
 #5 [ffff88007a8979f0] bad_area at ffffffff8163be4b
    /root/linux/arch/x86/mm/fault.c: 833
 #6 [ffff88007a897a20] __do_page_fault at ffffffff81057933
    /root/linux/arch/x86/mm/fault.c: 1220
 #7 [ffff88007a897b30] do_page_fault at ffffffff810579f1
    /root/linux/arch/x86/mm/fault.c: 1299
 #8 [ffff88007a897b60] page_fault at ffffffff816495e8
    /root/linux/arch/x86/kernel/entry_64.S: 1255
    [exception RIP: skb_queue_tail+55]
    RIP: ffffffff81535e27  RSP: ffff88007a897c18  RFLAGS: 00010046
    RAX: 0000000000000296  RBX: ffff8800360c0b10  RCX: 0000000000000000
    RDX: 0000000000000000  RSI: 0000000000000296  RDI: ffff8800360c0b24
    RBP: ffff88007a897c38   R8: 0000000000000296   R9: 0000000000000300
    R10: ffff88007f803600  R11: ffff88007a9dbd00  R12: ffff8800360c0b10
    R13: ffff8800360c0b24  R14: 0000000000000000  R15: 0000000000000000
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
 #9 [ffff88007a897c40] unix_stream_sendmsg at ffffffff815e9b11
    /root/linux/net/unix/af_unix.c: 1712
#10 [ffff88007a897d00] sock_aio_write at ffffffff8152cf2a
    /root/linux/net/socket.c: 980
#11 [ffff88007a897d90] do_sync_readv_writev at ffffffff811af8bc
    /root/linux/fs/read_write.c: 685
#12 [ffff88007a897e20] do_readv_writev at ffffffff811b1255
    /root/linux/fs/read_write.c: 839
#13 [ffff88007a897f20] vfs_writev at ffffffff811b1379
    /root/linux/fs/read_write.c: 881
#14 [ffff88007a897f30] sys_writev at ffffffff811b14aa
    /root/linux/fs/read_write.c: 914
#15 [ffff88007a897f80] system_call_fastpath at ffffffff81647729
    /root/linux/arch/x86/kernel/entry_64.S: 423
    RIP: 00007f51285923c0  RSP: 00007fff324a0e00  RFLAGS: 00013202
    RAX: ffffffffffffffda  RBX: ffffffff81647729  RCX: 00000000004c66f0
    RDX: 0000000000000001  RSI: 00007fff324a0840  RDI: 0000000000000013
    RBP: 000000000210e4b0   R8: 0000000000000000   R9: 0000000000400000
    R10: 0000000000000000  R11: 0000000000003293  R12: 00007f512a6b06a0
    R13: 0000000000000001  R14: 00007fff324a0840  R15: 0000000000000000
    ORIG_RAX: 0000000000000014  CS: 0033  SS: 002b
----------

void skb_queue_tail(struct sk_buff_head *list, struct sk_buff *newsk)
{
        unsigned long flags;

        spin_lock_irqsave(&list->lock, flags);
        __skb_queue_tail(list, newsk);
        spin_unlock_irqrestore(&list->lock, flags);
}

static inline void __skb_queue_tail(struct sk_buff_head *list,
                                   struct sk_buff *newsk)
{
        __skb_queue_before(list, (struct sk_buff *)list, newsk);
}

static inline void __skb_queue_before(struct sk_buff_head *list,
                                      struct sk_buff *next,
                                      struct sk_buff *newsk)
{
        __skb_insert(newsk, next->prev, next, list);
}

static inline void __skb_insert(struct sk_buff *newsk,
                                struct sk_buff *prev, struct sk_buff *next,
                                struct sk_buff_head *list)
{
        newsk->next = next;
        newsk->prev = prev;
        next->prev  = prev->next = newsk; // <= ffffffff81535e27 is here.
        list->qlen++;
}
