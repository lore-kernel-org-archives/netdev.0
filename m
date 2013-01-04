From: Christoph Lameter <cl@linux.com>
Subject: Re: load/unload dccp module caused oops
Date: Fri, 4 Jan 2013 15:05:35 +0000
Message-ID: <0000013c0618832c-11b14217-2010-4cdb-abb3-c1afcbc44145-000000@email.amazonses.com>
References: <2084106232.8072575.1357285039431.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Dave Miller <davem@redhat.com>,
	stable@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	Glauber Costa <glommer@parallels.com>
To: CAI Qian <caiqian@redhat.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <2084106232.8072575.1357285039431.JavaMail.root@redhat.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

See the fix available here:

https://patchwork.kernel.org/patch/1909861/


On Fri, 4 Jan 2013, CAI Qian wrote:

> The bisecting pointed out this commit fixed the problem in
> the mainline.
>
> 3c58346525d82625e68e24f071804c2dc057b6f4
> slab: Simplify bootstrap
>
> However, simply back-ported this single commit to the 3.7.1
> stable wasn't enough to fix it. My guess is that there are
> some other slab/slub commits required to fix this. Keep digging...
>
> The kernel config used the SLUB,
> http://people.redhat.com/qcai/stable/.config
>
> CAI Qian
>
> ----- Original Message -----
> > From: "CAI Qian" <caiqian@redhat.com>
> > To: netdev@vger.kernel.org
> > Cc: "Dave Miller" <davem@redhat.com>, stable@vger.kernel.org
> > Sent: Friday, January 4, 2013 9:57:43 AM
> > Subject: Re: load/unload dccp module caused
> >
> > Adding the netdev as Dave suggested.
> >
> > ----- Original Message -----
> > > From: "CAI Qian" <caiqian@redhat.com>
> > > To: stable@vger.kernel.org
> > > Cc: "Dave Miller" <davem@redhat.com>
> > > Sent: Monday, December 31, 2012 5:42:59 PM
> > > Subject: load/unload dccp module caused
> > >
> > > Just a head up that load and then unload the dccp module
> > > caused an oops below using the current stable kernel - v3.7.1.
> > > Some additional data point here: the mainline v3.6 release has
> > > no such problem, so this looks like a regression. The mainline
> > > v3.8-rc1 also has no such problem, so it looks like it has
> > > already been fixed there but looks like yet queued up for the
> > > stable yet (tested a few commits in Greg's stable-queue and
> > > Dave's net-stable queue did not find anything obvious to fix
> > > this). I am in-process to bisect to figure out the one that
> > > need to back-port right now.
> > >
> > > [   93.809573]
> > > =============================================================================
> > > [   93.809577] BUG kmalloc-16 (Tainted: G    B       ): Objects
> > > remaining in kmalloc-16 on kmem_cache_close()
> > > [   93.809580]
> > > -----------------------------------------------------------------------------
> > > [   93.809580]
> > > ...
> > > [  356.336244] INFO: Object 0xc0000000fa1f0aa0 @offset=2720
> > > [  356.336247] INFO: Object 0xc0000000fa1f0ab0 @offset=2736
> > > [  356.336249] INFO: Object 0xc0000000fa1f0ac0 @offset=2752
> > > [  356.336254] INFO: Object 0xc0000000fa1f0ad0 @offset=2768
> > > [  356.336257] INFO: Object 0xc0000000fa1f0ae0 @offset=2784
> > > [  356.336259] INFO: Object 0xc0000000fa1f0af0 @offset=2800
> > > [  356.336262] INFO: Object 0xc0000000fa1f0b80 @offset=2944
> > > [  356.336264] INFO: Object 0xc0000000fa1f0bd0 @offset=3024
> > > [  356.336271] INFO: Object 0xc0000000fa1f1870 @offset=6256
> > > [  356.336274] INFO: Object 0xc0000000fa1f1880 @offset=6272
> > > [  356.336276] INFO: Object 0xc0000000fa1f1890 @offset=6288
> > > [  356.346976] INFO: Object 0xc0000000fa1f18a0 @offset=6304
> > > [  356.346979] INFO: Object 0xc0000000fa1f18b0 @offset=6320
> > > [  356.346981] INFO: Object 0xc0000000fa1f1950 @offset=6480
> > > [  356.346986] INFO: Object 0xc0000000fa1f1960 @offset=6496
> > > [  356.346989] INFO: Object 0xc0000000fa1f1970 @offset=6512
> > > [  356.346991] INFO: Object 0xc0000000fa1f1980 @offset=6528
> > > [  356.346994] INFO: Object 0xc0000000fa1f1990 @offset=6544
> > > [  356.346997] INFO: Object 0xc0000000fa1f19a0 @offset=6560
> > > [  356.346999] INFO: Object 0xc0000000fa1f19b0 @offset=6576
> > > [  356.347005] INFO: Object 0xc0000000fa1f19c0 @offset=6592
> > > [  356.347008] INFO: Object 0xc0000000fa1f19d0 @offset=6608
> > > [  356.347010] INFO: Object 0xc0000000fa1f19e0 @offset=6624
> > > [  356.347012] INFO: Object 0xc0000000fa1f19f0 @offset=6640
> > > [  356.347081] kmem_cache_destroy kmalloc-16: Slab cache still has
> > > objects
> > > ...
> > > [441283.322161] BUG: unable to handle kernel NULL pointer
> > > dereference
> > > at           (null)
> > > [441283.331020] IP: [<ffffffff811785f9>]
> > > __kmem_cache_shutdown+0xa9/0x2f0
> > > [441283.338320] PGD 105568f067 PUD 104a086067 PMD 0
> > > [441283.343600] Oops: 0000 [#1] SMP
> > > [441283.347318] Modules linked in: dccp(-) nf_tproxy_core deflate
> > > zlib_deflate lzo nls_koi8_u nls_cp932 ts_kmp sctp libcrc32c
> > > binfmt_misc des_generic md4 nls_utf8 cifs dns_resolver sg iTCO_wdt
> > > kvm_intel igb iTCO_vendor_support coretemp kvm crc32c_intel lpc_ich
> > > i7core_edac edac_core i2c_i801 i2c_core mfd_core pcspkr microcode
> > > ioatdma dca sr_mod cdrom ata_generic sd_mod pata_acpi crc_t10dif
> > > ata_piix libata megaraid_sas dm_mirror dm_region_hash dm_log dm_mod
> > > [last unloaded: inet_diag]
> > > [441283.395187] CPU 6
> > > [441283.397337] Pid: 40979, comm: modprobe Tainted: G    B
> > >        3.7.1+ #10 QCI QSSC-S4R/QSSC-S4R
> > > [441283.407245] RIP: 0010:[<ffffffff811785f9>]
> > >  [<ffffffff811785f9>]
> > > __kmem_cache_shutdown+0xa9/0x2f0
> > > [441283.417256] RSP: 0018:ffff88205247de08  EFLAGS: 00010292
> > > [441283.423280] RAX: ffff881059780001 RBX: ffff88085acfa000 RCX:
> > > 00000000001c7d72
> > > [441283.431336] RDX: 00000000001c7d71 RSI: 0000000000000ff0 RDI:
> > > ffff88085f802600
> > > [441283.439394] RBP: ffff88205247de68 R08: 0000000000016940 R09:
> > > ffff88105fd36940
> > > [441283.447451] R10: ffffea004165e000 R11: ffffffff81178721 R12:
> > > ffffffffffffffe0
> > > [441283.455508] R13: ffff88085acf9000 R14: ffff88085f802500 R15:
> > > ffffea00216b3e40
> > > [441283.463565] FS:  00007fd36f206740(0000)
> > > GS:ffff88105fc20000(0000)
> > > knlGS:0000000000000000
> > > [441283.472687] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > > [441283.479194] CR2: 00007fd545ae9c74 CR3: 000000104a273000 CR4:
> > > 00000000000007e0
> > > [441283.487251] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> > > 0000000000000000
> > > [441283.495308] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> > > 0000000000000400
> > > [441283.503366] Process modprobe (pid: 40979, threadinfo
> > > ffff88205247c000, task ffff8820493fb240)
> > > [441283.512974] Stack:
> > > [441283.515312]  ffffffffa0169760 ffff8810597800c0 0000000000000000
> > > 0000000000000000
> > > [441283.523705]  ffff88085f8010d0 ffff88085f8010c0 ffff88205247de68
> > > ffff88085f802500
> > > [441283.532104]  ffff88085f802568 0000000000000000 00000000011ec578
> > > 0000000000000000
> > > [441283.540499] Call Trace:
> > > [441283.543328]  [<ffffffff8114993a>] kmem_cache_destroy+0x3a/0xe0
> > > [441283.549941]  [<ffffffffa0164c0a>] tfrc_li_exit+0x1a/0x30 [dccp]
> > > [441283.556649]  [<ffffffffa01635e8>] tfrc_lib_exit+0x18/0x20
> > > [dccp]
> > > [441283.563451]  [<ffffffffa01583e6>]
> > > ccid_cleanup_builtins+0x26/0x30
> > > [dccp]
> > > [441283.571032]  [<ffffffffa0164e33>] dccp_fini+0xe/0x1db [dccp]
> > > [441283.577449]  [<ffffffffa0164e25>] ? scaled_div.part.0+0x6/0x6
> > > [dccp]
> > > [441283.584639]  [<ffffffff810bc3fe>] sys_delete_module+0x16e/0x2d0
> > > [441283.591342]  [<ffffffff810d851c>] ?
> > > __audit_syscall_entry+0xcc/0x300
> > > [441283.598530]  [<ffffffff810d8b3c>] ?
> > > __audit_syscall_exit+0x3ec/0x450
> > > [441283.605719]  [<ffffffff815d3b99>]
> > > system_call_fastpath+0x16/0x1b
> > > [441283.612516] Code: 48 39 d7 4d 89 ec 75 41 e9 55 01 00 00 0f 1f
> > > 44
> > > 00 00 e8 0b f7 16 00 48 8b 55 c8 4c 89 fe 4c 89 f7 48 83 6a 08 01
> > > e8
> > > 97 c6 ff ff <49> 8b 44 24 20 49 8d 7c 24 20 4d 89 e7 48 83 e8 20 48
> > > 39 7d c0
> > > [441283.634440] RIP  [<ffffffff811785f9>]
> > > __kmem_cache_shutdown+0xa9/0x2f0
> > > [441283.641831]  RSP <ffff88205247de08>
> > > [441283.645817] CR2: 0000000000000000
> > > [441283.649815] ---[ end trace 8e20d31634421a27 ]---
> > >
> > > CAI Qian
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe stable"
> > > in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > >
> > --
> > To unsubscribe from this list: send the line "unsubscribe stable" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
>
