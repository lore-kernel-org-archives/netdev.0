From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [bpf]  3ea693a925: BUG:unable_to_handle_kernel
Date: Wed, 25 Oct 2017 19:59:17 +0300
Message-ID: <20171025195757-mutt-send-email-mst@kernel.org>
References: <150711862505.9499.15042356194495111353.stgit@firesoul>
 <20171025165323.hdordanzbhkiap7d@inn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
        jakub.kicinski@netronome.com, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, lkp@01.org,
        syzkaller@googlegroups.com
To: kernel test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33260 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932231AbdJYQ70 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 12:59:26 -0400
Content-Disposition: inline
In-Reply-To: <20171025165323.hdordanzbhkiap7d@inn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 12:53:23AM +0800, kernel test robot wrote:
> FYI, we noticed the following commit (built with gcc-6):
> 
> commit: 3ea693a925e14c1fc54c7d8bebe6f9fd9441b47d ("bpf: introduce new bpf cpu map type BPF_MAP_TYPE_CPUMAP")
> url: https://github.com/0day-ci/linux/commits/Jesper-Dangaard-Brouer/New-bpf-cpumap-type-for-XDP_REDIRECT/20171006-024959
> 
> 
> in testcase: syzkaller
> with following parameters:
> 
> 	runtime: 10
> 	repro_program: repro-68782ef7
> 
> 
> 
> on test machine: qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 4G
> 
> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):
> 
> 
> +------------------------------------------+------------+------------+
> |                                          | 14a0d032f4 | 3ea693a925 |
> +------------------------------------------+------------+------------+
> | boot_successes                           | 8          | 4          |
> | boot_failures                            | 0          | 3          |
> | BUG:unable_to_handle_kernel              | 0          | 3          |
> | Oops:#[##]                               | 0          | 3          |
> | Kernel_panic-not_syncing:Fatal_exception | 0          | 3          |
> +------------------------------------------+------------+------------+
> 
> 
> 
> [   55.527578] BUG: unable to handle kernel paging request at ffffffff871ae788
> [   55.527597] IP: cpu_map_update_elem+0x4d/0x2e0
> [   55.527600] PGD 4e26067 P4D 4e26067 PUD 4e27063 PMD 0 
> [   55.527610] Oops: 0000 [#1] SMP KASAN
> [   55.527613] Modules linked in:
> [   55.527622] CPU: 0 PID: 6619 Comm: repro-68782ef7 Not tainted 4.14.0-rc1-00610-g3ea693a #1
> [   55.527625] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [   55.527629] task: ffff8800ae0d48c0 task.stack: ffff8800af840000
> [   55.527636] RIP: 0010:cpu_map_update_elem+0x4d/0x2e0
> [   55.527638] RSP: 0018:ffff8800af847d50 EFLAGS: 00010246
> [   55.527643] RAX: 000000000e601b02 RBX: ffff880118909c18 RCX: 0000000000000002
> [   55.527647] RDX: 0000000000000000 RSI: ffff880118909c18 RDI: ffff88007ed5e300
> [   55.527650] RBP: ffff8800af847d78 R08: ffffed0023121386 R09: ffffed0023121386
> [   55.527653] R10: 0000000000000003 R11: ffffed0023121387 R12: ffff88007ed5e300
> [   55.527656] R13: ffff880118909c30 R14: 0000000000000002 R15: 000000000e601b02
> [   55.527660] FS:  00007f8f76205800(0000) GS:ffff88011ac00000(0000) knlGS:0000000000000000
> [   55.527663] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   55.527666] CR2: ffffffff871ae788 CR3: 00000000af118000 CR4: 00000000000006f0
> [   55.527673] Call Trace:
> [   55.527682]  SyS_bpf+0x2977/0x3600
> [   55.527690]  ? bpf_prog_get+0x20/0x20
> [   55.527700]  ? lock_downgrade+0x650/0x650
> [   55.527708]  ? vmacache_find+0x59/0x260
> [   55.527716]  ? up_read+0x1a/0x40
> [   55.527724]  ? __do_page_fault+0x350/0xae0
> [   55.527735]  ? entry_SYSCALL_64_fastpath+0x5/0xbe
> [   55.527743]  ? trace_hardirqs_on_thunk+0x1a/0x1c
> [   55.527753]  entry_SYSCALL_64_fastpath+0x1f/0xbe
> [   55.527758] RIP: 0033:0x7f8f75d2cd49
> [   55.527760] RSP: 002b:00007fffed5cc7d8 EFLAGS: 00000216 ORIG_RAX: 0000000000000141
> [   55.527765] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f8f75d2cd49
> [   55.527768] RDX: 0000000000000020 RSI: 00000000202ebfe0 RDI: 0000000000000002
> [   55.527771] RBP: 0000000000000046 R08: 0000000000000000 R09: 0000000000000000
> [   55.527774] R10: 0000000000000000 R11: 0000000000000216 R12: 0000000000400a70
> [   55.527777] R13: 00007fffed5cc980 R14: 0000000000000000 R15: 0000000000000000
> [   55.527786] Code: b8 00 00 00 00 00 fc ff df 48 c1 ea 03 0f b6 14 02 48 89 d8 83 e0 07 83 c0 03 38 d0 7c 08 84 d2 0f 85 54 02 00 00 8b 03 49 89 c7 <48> 0f a3 05 f3 0d fa 03 0f 83 6f 02 00 00 e8 c0 64 f2 ff 49 83 
> [   55.527870] RIP: cpu_map_update_elem+0x4d/0x2e0 RSP: ffff8800af847d50
> [   55.527872] CR2: ffffffff871ae788
> [   55.527881] ---[ end trace 1f2b13c8215f4b2c ]---
> 
> 
> To reproduce:
> 
>         git clone https://github.com/intel/lkp-tests.git
>         cd lkp-tests
>         bin/lkp qemu -k <bzImage> job-script  # job-script is attached in this email
> 
> 
> 
> Thanks,
> lkp

That commit has a different hash in net-next:

commit 6710e1126934d8b4372b4d2f9ae1646cd3f151bf
Author: Jesper Dangaard Brouer <brouer@redhat.com>
Date:   Mon Oct 16 12:19:28 2017 +0200

    bpf: introduce new bpf cpu map type BPF_MAP_TYPE_CPUMAP

Is this from a private tree?

-- 
MST
