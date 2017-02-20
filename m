From: Eric Dumazet <edumazet@google.com>
Subject: Re: [lkp-robot] [tcp] e70ac17165: WARNING:at_kernel/softirq.c:#__local_bh_enable_ip
Date: Mon, 20 Feb 2017 08:27:53 -0800
Message-ID: <CANn89i+=siVUhXTxzOOhs_AyZ=0CJeFvXYNPbxfPcTzd=-pVEw@mail.gmail.com>
References: <20170220021159.GA28799@yexl-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Ricardo Nabinger Sanchez <rnsanchez@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKP <lkp@01.org>, netdev <netdev@vger.kernel.org>
To: kernel test robot <xiaolong.ye@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35060 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751538AbdBTQ1z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 11:27:55 -0500
Received: by mail-io0-f169.google.com with SMTP id j18so29234734ioe.2
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 08:27:55 -0800 (PST)
In-Reply-To: <20170220021159.GA28799@yexl-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 19, 2017 at 6:11 PM, kernel test robot
<xiaolong.ye@intel.com> wrote:
>
> FYI, we noticed the following commit:
>
> commit: e70ac171658679ecf6bea4bbd9e9325cd6079d2b ("tcp: tcp_probe: use sp=
in_lock_bh()")
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git master
>
> in testcase: boot
>
> on test machine: qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 2G
>
> caused below changes (please refer to attached dmesg/kmsg for entire log/=
backtrace):
>
>
> +-----------------------------------------------------+------------+-----=
-------+
> |                                                     | a725eb15db | e70a=
c17165 |
> +-----------------------------------------------------+------------+-----=
-------+
> | boot_successes                                      | 0          | 0   =
       |
> | boot_failures                                       | 14         | 16  =
       |
> | WARNING:at_arch/x86/mm/dump_pagetables.c:#note_page | 14         | 16  =
       |
> | invoked_oom-killer:gfp_mask=3D0x                      | 0          | 3 =
         |
> | Mem-Info                                            | 0          | 3   =
       |
> | Out_of_memory:Kill_process                          | 0          | 1   =
       |
> | WARNING:at_kernel/softirq.c:#__local_bh_enable_ip   | 0          | 11  =
       |
> +-----------------------------------------------------+------------+-----=
-------+
>
>
>
> [   27.257372] WARNING: CPU: 1 PID: 483 at kernel/softirq.c:161 __local_b=
h_enable_ip+0x3b/0x80
> [   27.259647] Modules linked in: auth_rpcgss nfsv4 nfs lockd grace fscac=
he af_packet ide_cd_mod ide_pci_generic crct10dif_pclmul crct10dif_common b=
ochs_drm ttm crc32c_intel fbcon bitblit fbcon_rotate fbcon_ccw fbcon_ud fbc=
on_cw softcursor font tileblit drm_kms_helper input_leds serio_raw drm i630=
0esb virtio_pci piix e1000 ide_core i2c_piix4 tpm_tis tpm_tis_core floppy q=
emu_fw_cfg evbug evdev sunrpc ip_tables ipv6 autofs4
> [   27.266515] CPU: 1 PID: 483 Comm: mount.nfs Tainted: G        W       =
4.10.0-rc7-00193-ge70ac17 #2
> [   27.267842] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S 1.9.3-20161025_171302-gandalf 04/01/2014
> [   27.269268] Call Trace:
> [   27.270086]  dump_stack+0x63/0x81
> [   27.271046]  __warn+0xbb/0xe0
> [   27.271932]  warn_slowpath_null+0x18/0x20
> [   27.272848]  __local_bh_enable_ip+0x3b/0x80
> [   27.273806]  _raw_spin_unlock_bh+0x30/0x40
> [   27.274736]  jtcp_rcv_established+0x297/0x2c0
> [   27.275714]  tcp_v4_do_rcv+0x96/0x150
> [   27.276586]  __release_sock+0xce/0x150
> [   27.277451]  release_sock+0x2b/0xb0
> [   27.278297]  tcp_sendmsg+0x9ea/0xaf0
> [   27.279199]  inet_sendmsg+0xd4/0x100
> [   27.280070]  kernel_sendmsg+0x30/0x40
> [   27.280947]  xs_send_kvec+0x6b/0x90 [sunrpc]
> [   27.281826]  xs_sendpages+0x5e/0x1e0 [sunrpc]
> [   27.282763]  xs_tcp_send_request+0x7d/0x160 [sunrpc]
> [   27.283680]  xprt_transmit+0xbb/0x280 [sunrpc]
> [   27.284538]  call_transmit+0x1cc/0x240 [sunrpc]
> [   27.285445]  ? rpc_destroy_wait_queue+0x20/0x20 [sunrpc]
> [   27.286358]  __rpc_execute+0x83/0x200 [sunrpc]
> [   27.287257]  ? wake_up_bit+0x20/0x30
> [   27.288072]  rpc_execute+0x38/0x40 [sunrpc]
> [   27.288934]  rpc_run_task+0x14b/0x160 [sunrpc]
> [   27.289774]  rpc_call_sync+0x7f/0xa0 [sunrpc]
> [   27.290629]  rpc_ping+0x4d/0x70 [sunrpc]
> [   27.291479]  rpc_create_xprt+0xde/0x170 [sunrpc]
> [   27.292339]  rpc_create+0x198/0x1c0 [sunrpc]
> [   27.293166]  ? rpcauth_lookup_credcache+0x204/0x2c0 [sunrpc]
> [   27.294103]  nfs_create_rpc_client+0xcd/0xf0 [nfs]
> [   27.295010]  nfs4_init_client+0x82/0x1c0 [nfsv4]
> [   27.295916]  ? nfs_get_client+0x36b/0x3c0 [nfs]
> [   27.296759]  ? kvm_sched_clock_read+0x25/0x40
> [   27.297572]  ? sched_clock+0x9/0x10
> [   27.298319]  ? sched_clock_cpu+0xa5/0xb0
> [   27.299109]  ? nfs_get_client+0x36b/0x3c0 [nfs]
> [   27.299938]  ? nfs_get_client+0xb4/0x3c0 [nfs]
> [   27.300778]  ? __lock_acquire+0x87d/0x940
> [   27.301649]  nfs_get_client+0x382/0x3c0 [nfs]
> [   27.302473]  ? nfs_get_client+0xb4/0x3c0 [nfs]
> [   27.303395]  ? is_module_address+0x10/0x20
> [   27.304179]  nfs4_set_client+0x76/0xa0 [nfsv4]
> [   27.304949]  nfs4_create_server+0x10b/0x270 [nfsv4]
> [   27.305796]  nfs4_remote_mount+0x29/0x50 [nfsv4]
> [   27.306543]  mount_fs+0xf/0x90
> [   27.307210]  vfs_kern_mount+0x6b/0x170
> [   27.307859]  nfs_do_root_mount+0x93/0xc0 [nfsv4]
> [   27.308668]  nfs4_try_mount+0x32/0x50 [nfsv4]
> [   27.309402]  nfs_fs_mount+0x8aa/0x950 [nfs]
> [   27.310045]  ? nfs_remount+0x3c0/0x3c0 [nfs]
> [   27.310766]  ? nfs_auth_info_match+0x40/0x40 [nfs]
> [   27.311521]  mount_fs+0xf/0x90
> [   27.312090]  vfs_kern_mount+0x6b/0x170
> [   27.312716]  do_mount+0x9c4/0xd40
> [   27.313323]  ? copy_mount_options+0x28/0x160
> [   27.313973]  SyS_mount+0x8c/0xc0
> [   27.314552]  do_syscall_64+0x7d/0x160
> [   27.315186]  entry_SYSCALL64_slow_path+0x25/0x25
> [   27.315911] RIP: 0033:0x7f2c30cd598a
> [   27.316520] RSP: 002b:00007fff1bf85388 EFLAGS: 00000206 ORIG_RAX: 0000=
0000000000a5
> [   27.317600] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f2c3=
0cd598a
> [   27.319087] RDX: 0000000001b9cf30 RSI: 0000000001b9cf10 RDI: 000000000=
1b9cef0
> [   27.320581] RBP: 00007fff1bf85490 R08: 0000000001b9d890 R09: 000000000=
1b9d890
> [   27.322077] R10: 0000000000000000 R11: 0000000000000206 R12: 00007fff1=
bf85490
> [   27.323571] R13: 0000000001b9d650 R14: 0000000000000010 R15: 000000000=
1b9b010
> [   27.325060] ---[ end trace 1b69e98171ee3b1d ]---
>
>
> To reproduce:
>
>         git clone git://git.kernel.org/pub/scm/linux/kernel/git/wfg/lkp-t=
ests.git
>         cd lkp-tests
>         bin/lkp qemu -k <bzImage> job-script  # job-script is attached in=
 this email
>
>
>
> Thanks,
> Xiaolong

Thanks for the report, I will take a look.
Apparently jprobe invokes us with hard irq disabled (at least on x86)
