From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Fri, 12 Feb 2016 11:36:24 +0100
Message-ID: <56BDB5A8.9030006@suse.cz>
References: <cover.1453405861.git.jpoimboe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, live-patching@vger.kernel.org,
	Michal Marek <mmarek@suse.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Pedro Alves <palves@redhat.com>,
	Namhyung Kim <namhyung@gmail.com>,
	Bernd Petrovitsch <bernd@petrovitsch.priv.at>,
	Chris J Arges <chris.j.arges@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Borislav Petkov <bp@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Alok Kataria <akataria@vmware.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.o
To: Josh Poimboeuf <jpoimboe@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1453405861.git.jpoimboe@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/21/2016, 11:49 PM, Josh Poimboeuf wrote:
> This is v16 of the compile-time stack metadata validation patch set,
> along with proposed fixes for most of the warnings it found.  It's based
> on the tip/master branch.

Hi,

with this config:
https://github.com/openSUSE/kernel-source/blob/master/config/x86_64/vanilla

I am seeing a lot of functions in C which do not have frame pointer setup/cleanup:
stacktool: drivers/scsi/hpsa.o: hpsa_scsi_do_simple_cmd.constprop.106()+0x79: call without frame pointer save/setup
stacktool: drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.o: cfs_cdebug_show.part.5.constprop.35()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.o: cfs_cdebug_show.part.5.constprop.35()+0x8: duplicate frame pointer save
stacktool: drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.o: cfs_cdebug_show.part.5.constprop.35()+0x9: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lnet/klnds/socklnd/socklnd.o: ksocknal_connsock_decref()+0x0: duplicate frame pointer save
stacktool: drivers/staging/lustre/lnet/klnds/socklnd/socklnd.o: ksocknal_connsock_decref()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lnet/klnds/socklnd/socklnd.o: ksocknal_connsock_decref()+0x1: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lnet/klnds/socklnd/socklnd.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lnet/lnet/lib-move.o: cfs_cdebug_show.part.1.constprop.16()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lnet/lnet/lib-move.o: cfs_cdebug_show.part.1.constprop.16()+0x8: duplicate frame pointer save
stacktool: drivers/staging/lustre/lnet/lnet/lib-move.o: cfs_cdebug_show.part.1.constprop.16()+0x9: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lnet/lnet/lib-move.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lnet/lnet/lo.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lnet/lnet/nidstrings.o: cfs_print_nidlist()+0x220: frame pointer state mismatch
stacktool: drivers/staging/lustre/lnet/lnet/peer.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lnet/lnet/router.o: cfs_cdebug_show.part.0.constprop.16()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lnet/lnet/router.o: cfs_cdebug_show.part.0.constprop.16()+0x8: duplicate frame pointer save
stacktool: drivers/staging/lustre/lnet/lnet/router.o: cfs_cdebug_show.part.0.constprop.16()+0x9: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lnet/lnet/router.o: lnet_find_net_locked()+0x8a: frame pointer state mismatch
stacktool: drivers/staging/lustre/lnet/lnet/router.o: lnet_find_net_locked()+0x8a: return without frame pointer restore
stacktool: drivers/staging/lustre/lustre/fid/fid_request.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/fld/lproc_fld.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/libcfs/libcfs_lock.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/libcfs/libcfs_mem.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/llite/dir.o: obd_unpackmd()+0x0: duplicate frame pointer save
stacktool: drivers/staging/lustre/lustre/llite/dir.o: obd_unpackmd()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/llite/dir.o: obd_unpackmd()+0x4: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lustre/llite/file.o: md_intent_lock.part.28()+0x0: duplicate frame pointer save
stacktool: drivers/staging/lustre/lustre/llite/file.o: md_intent_lock.part.28()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/llite/file.o: md_intent_lock.part.28()+0x24: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lustre/llite/../lclient/glimpse.o: cl_io_get()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/llite/../lclient/glimpse.o: cl_io_get()+0x1a: duplicate frame pointer save
stacktool: drivers/staging/lustre/lustre/llite/../lclient/glimpse.o: cl_io_get()+0x1b: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lustre/llite/../lclient/glimpse.o: cl_io_get()+0x19: return without frame pointer restore
stacktool: drivers/staging/lustre/lustre/llite/../lclient/lcommon_misc.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/llite/llite_mmap.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/llite/lproc_llite.o: checksum_pages_store()+0x19e: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/llite/namei.o: ll_test_inode()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/llite/namei.o: ll_test_inode()+0x5: duplicate frame pointer save
stacktool: drivers/staging/lustre/lustre/llite/namei.o: ll_test_inode()+0x9: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lustre/llite/rw.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/llite/statahead.o: md_revalidate_lock.part.26()+0x0: duplicate frame pointer save
stacktool: drivers/staging/lustre/lustre/llite/statahead.o: md_revalidate_lock.part.26()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/llite/statahead.o: md_revalidate_lock.part.26()+0x24: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lustre/llite/statahead.o: sa_args_fini()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/llite/statahead.o: sa_args_fini()+0x5: duplicate frame pointer save
stacktool: drivers/staging/lustre/lustre/llite/statahead.o: sa_args_fini()+0x9: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lustre/llite/statahead.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/llite/vvp_page.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/llite/xattr_cache.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/llite/xattr.o: get_xattr_type()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/llite/xattr.o: get_xattr_type()+0x1f: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lustre/llite/xattr.o: get_xattr_type()+0x5: duplicate frame pointer save
stacktool: drivers/staging/lustre/lustre/lmv/lmv_intent.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/lmv/lmv_obd.o: __lmv_fid_alloc()+0x185: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/lov/lov_io.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/lov/lovsub_dev.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/mdc/mdc_lib.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/mdc/mdc_locks.o: .text.unlikely: unexpected end of section
stacktool: drivers/staging/lustre/lustre/obdclass/debug.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/obdclass/genops.o: class_name2dev()+0xc7: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/obdclass/lustre_handles.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/obdclass/obd_config.o: lustre_cfg_string()+0x0: duplicate frame pointer save
stacktool: drivers/staging/lustre/lustre/obdclass/obd_config.o: lustre_cfg_string()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/obdclass/obd_config.o: lustre_cfg_string()+0x4: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lustre/osc/osc_cache.o: __client_obd_list_lock()+0x0: duplicate frame pointer save
stacktool: drivers/staging/lustre/lustre/osc/osc_cache.o: __client_obd_list_lock()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/osc/osc_cache.o: __client_obd_list_lock()+0x1: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lustre/osc/osc_cache.o: osc_extent_search()+0x78: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/osc/osc_cache.o: osc_extent_search()+0x78: return without frame pointer restore
stacktool: drivers/staging/lustre/lustre/osc/osc_dev.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/osc/osc_page.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/ptlrpc/connection.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/ptlrpc/import.o: deuuidify.constprop.8()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/ptlrpc/import.o: deuuidify.constprop.8()+0x5: duplicate frame pointer save
stacktool: drivers/staging/lustre/lustre/ptlrpc/import.o: deuuidify.constprop.8()+0x6: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lustre/ptlrpc/llog_net.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/ldlm_extent.o: ldlm_extent_shift_kms()+0x93: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/ldlm_lock.o: ldlm_work_bl_ast_lock()+0x156: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/ldlm_lock.o: ldlm_work_cp_ast_lock()+0xda: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/ptlrpc/nrs.o: nrs_policy_register()+0x0: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/ptlrpc/nrs.o: nrs_policy_register()+0x5: duplicate frame pointer save
stacktool: drivers/staging/lustre/lustre/ptlrpc/nrs.o: nrs_policy_register()+0x6: duplicate frame pointer setup
stacktool: drivers/staging/lustre/lustre/ptlrpc/nrs.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/ptlrpc/pack_generic.o: lustre_swab_mgs_nidtbl_entry()+0x89: frame pointer state mismatch
stacktool: drivers/staging/lustre/lustre/ptlrpc/pack_generic.o: lustre_swab_mgs_nidtbl_entry()+0x89: return without frame pointer restore
stacktool: drivers/staging/lustre/lustre/ptlrpc/sec_bulk.o: .text: unexpected end of section
stacktool: drivers/staging/lustre/lustre/ptlrpc/sec_config.o: .text: unexpected end of section
stacktool: fs/mbcache.o: mb_cache_entry_find_first()+0x70: call without frame pointer save/setup
stacktool: fs/mbcache.o: mb_cache_entry_find_first()+0x92: call without frame pointer save/setup
stacktool: fs/mbcache.o: mb_cache_entry_free()+0xff: call without frame pointer save/setup
stacktool: fs/mbcache.o: mb_cache_entry_free()+0xf5: call without frame pointer save/setup
stacktool: fs/mbcache.o: mb_cache_entry_free()+0x11a: call without frame pointer save/setup
stacktool: fs/mbcache.o: mb_cache_entry_get()+0x225: call without frame pointer save/setup
stacktool: kernel/locking/percpu-rwsem.o: percpu_up_read()+0x27: call without frame pointer save/setup
stacktool: kernel/profile.o: do_profile_hits.isra.5()+0x139: call without frame pointer save/setup
stacktool: lib/nmi_backtrace.o: nmi_trigger_all_cpu_backtrace()+0x2b6: call without frame pointer save/setup
stacktool: net/rds/ib_cm.o: rds_ib_cq_comp_handler_recv()+0x58: call without frame pointer save/setup
stacktool: net/rds/ib_cm.o: rds_ib_cq_comp_handler_send()+0x58: call without frame pointer save/setup
stacktool: net/rds/ib_recv.o: rds_ib_attempt_ack()+0xc1: call without frame pointer save/setup
stacktool: net/rds/iw_recv.o: rds_iw_attempt_ack()+0xc1: call without frame pointer save/setup
stacktool: net/rds/iw_recv.o: rds_iw_recv_cq_comp_handler()+0x55: call without frame pointer save/setup



For example do_profile_hits.isra.5:
0000000000003360 <hpsa_scsi_do_simple_cmd.constprop.106>:
    3360:       e8 00 00 00 00          callq  3365 <hpsa_scsi_do_simple_cmd.constprop.106+0x5>
                        3361: R_X86_64_PC32     __fentry__-0x4
    3365:       65 ff 05 00 00 00 00    incl   %gs:0x0(%rip)        # 336c <hpsa_scsi_do_simple_cmd.constprop.106+0xc>
                        3368: R_X86_64_PC32     __preempt_count-0x4
    336c:       65 8b 0d 00 00 00 00    mov    %gs:0x0(%rip),%ecx        # 3373 <hpsa_scsi_do_simple_cmd.constprop.106+0x13>
                        336f: R_X86_64_PC32     cpu_number-0x4
    3373:       48 63 c9                movslq %ecx,%rcx
    3376:       48 8b 87 b8 4b 00 00    mov    0x4bb8(%rdi),%rax
    337d:       48 8b 0c cd 00 00 00    mov    0x0(,%rcx,8),%rcx
    3384:       00 
                        3381: R_X86_64_32S      __per_cpu_offset
    3385:       8b 04 01                mov    (%rcx,%rax,1),%eax
    3388:       65 ff 0d 00 00 00 00    decl   %gs:0x0(%rip)        # 338f <hpsa_scsi_do_simple_cmd.constprop.106+0x2f>
                        338b: R_X86_64_PC32     __preempt_count-0x4
    338f:       74 48                   je     33d9 <hpsa_scsi_do_simple_cmd.constprop.106+0x79>
    3391:       85 c0                   test   %eax,%eax
    3393:       75 4d                   jne    33e2 <hpsa_scsi_do_simple_cmd.constprop.106+0x82>
    3395:       55                      push   %rbp
    3396:       48 89 e5                mov    %rsp,%rbp
    3399:       53                      push   %rbx
    339a:       48 8d 5d d8             lea    -0x28(%rbp),%rbx
    339e:       48 83 ec 20             sub    $0x20,%rsp
    33a2:       c7 45 d8 00 00 00 00    movl   $0x0,-0x28(%rbp)
    33a9:       c7 45 e0 00 00 00 00    movl   $0x0,-0x20(%rbp)
    33b0:       48 8d 43 10             lea    0x10(%rbx),%rax
    33b4:       48 89 9e 54 02 00 00    mov    %rbx,0x254(%rsi)
    33bb:       48 89 45 e8             mov    %rax,-0x18(%rbp)
    33bf:       48 89 45 f0             mov    %rax,-0x10(%rbp)
    33c3:       e8 f8 ce ff ff          callq  2c0 <__enqueue_cmd_and_start_io>
    33c8:       48 89 df                mov    %rbx,%rdi
    33cb:       e8 00 00 00 00          callq  33d0 <hpsa_scsi_do_simple_cmd.constprop.106+0x70>
                        33cc: R_X86_64_PC32     wait_for_completion_io-0x4
    33d0:       48 83 c4 20             add    $0x20,%rsp
    33d4:       31 c0                   xor    %eax,%eax
    33d6:       5b                      pop    %rbx
    33d7:       5d                      pop    %rbp
    33d8:       c3                      retq   
    33d9:       e8 00 00 00 00          callq  33de <hpsa_scsi_do_simple_cmd.constprop.106+0x7e>
                        33da: R_X86_64_PC32     ___preempt_schedule-0x4
    33de:       85 c0                   test   %eax,%eax
    33e0:       74 b3                   je     3395 <hpsa_scsi_do_simple_cmd.constprop.106+0x35>
    33e2:       48 8b 86 38 02 00 00    mov    0x238(%rsi),%rax
    33e9:       ba ff ff ff ff          mov    $0xffffffff,%edx
    33ee:       66 89 50 02             mov    %dx,0x2(%rax)
    33f2:       31 c0                   xor    %eax,%eax
    33f4:       c3                      retq   
    33f5:       90                      nop
    33f6:       66 2e 0f 1f 84 00 00    nopw   %cs:0x0(%rax,%rax,1)
    33fd:       00 00 00 

It there some compilation flag missing? -f flags when compiling that file are:
-falign-jumps=1
-falign-loops=1
-fconserve-stack
-fno-asynchronous-unwind-tables
-fno-common
-fno-delete-null-pointer-checks
-fno-inline-functions-called-once
-fno-omit-frame-pointer
-fno-optimize-sibling-calls
-fno-strict-aliasing
-fno-strict-overflow
-fno-var-tracking-assignments
-fstack-protector
-funit-at-a-time

thanks,
-- 
js
suse labs
