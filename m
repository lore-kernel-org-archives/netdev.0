From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: WARNING: at net/core/neighbour.c:1545 neigh_table_init()
Date: Sun, 10 Feb 2013 02:04:55 +0900
Message-ID: <511681B7.5080002@linux-ipv6.org>
References: <20130209123937.GA23420@localhost> <1360421780.6696.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360421780.6696.24.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> On Sat, 2013-02-09 at 20:39 +0800, Fengguang Wu wrote:
>> Greetings,
>>
>> I got the below oops in linux-next and the first bad commit is
>>
>> commit 455e987c0c2eb2c9045dc854559474cf41509965
>> Merge: 7c17e48 fd6da69
>> Author: Linus Torvalds <torvalds@linux-foundation.org>
>> Date:   Sat Dec 1 13:07:48 2012 -0800
>>
>>     Merge branch 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>>     
>>     Pull perf fixes from Ingo Molnar:
>>      "This is mostly about unbreaking architectures that took the UAPI
>>       changes in the v3.7 cycle, plus misc fixes."
>>     
>>     * 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip:
>>       perf kvm: Fix building perf kvm on non x86 arches
>>       perf kvm: Rename perf_kvm to perf_kvm_stat
>>       perf: Make perf build for x86 with UAPI disintegration applied
>>       perf powerpc: Use uapi/unistd.h to fix build error
>>       tools: Pass the target in descend
>>       tools: Honour the O= flag when tool build called from a higher Makefile
>>       tools: Define a Makefile function to do subdir processing
>>       x86: Export asm/{svm.h,vmx.h,perf_regs.h}
>>       perf tools: Fix strbuf_addf() when the buffer needs to grow
>>       perf header: Fix numa topology printing
>>       perf, powerpc: Fix hw breakpoints returning -ENOSPC
>>
>> [  108.102297] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team
>> [  108.105501] ------------[ cut here ]------------
>> [  108.106286] WARNING: at /c/kernel-tests/src/i386/net/core/neighbour.c:1545 neigh_table_init+0x16f/0x490()
>> [  108.107506] Hardware name: Bochs
>> [  108.108577] Pid: 1, comm: swapper Not tainted 3.8.0-rc5-01118-geee5035 #17
>> [  108.109506] Call Trace:
>> [  108.111179]  [<c1054e52>] warn_slowpath_common+0xf2/0x140
>> [  108.112064]  [<c1acc2af>] ? neigh_table_init+0x16f/0x490
>> [  108.112880]  [<c1acc2af>] ? neigh_table_init+0x16f/0x490
>> [  108.114164]  [<c24d8c67>] ? atm_clip_init+0x98/0x98
>> [  108.115409]  [<c1054ff9>] warn_slowpath_null+0x39/0x50
>> [  108.116776]  [<c1acc2af>] neigh_table_init+0x16f/0x490
>> [  108.118169]  [<c1d0ba16>] ? mutex_unlock+0x16/0x30
>> [  108.119260]  [<c1a9cbf5>] ? proto_register+0x65/0x350
>> [  108.120016]  [<c24d8c67>] ? atm_clip_init+0x98/0x98
>> [  108.121591]  [<c24d91c6>] dn_neigh_init+0x1b/0x2b
>> [  108.122305]  [<c24d8cce>] decnet_init+0x67/0xfc
>> [  108.123169]  [<c2472470>] do_one_initcall+0xf2/0x259
>> [  108.124259]  [<c24727fa>] kernel_init_freeable+0x223/0x393
>> [  108.125053]  [<c2471548>] ? loglevel+0x55/0x55
>> [  108.125712]  [<c1ce8b59>] kernel_init+0x19/0x200
>> [  108.126411]  [<c1d114fb>] ret_from_kernel_thread+0x1b/0x30
>> [  108.127194]  [<c1ce8b40>] ? rest_init+0x1f0/0x1f0
>> [  108.128351] ---[ end trace 1bcbb5f262552fec ]---
>>
>> git bisect start v3.7 v3.6 --
>> git bisect good d66e6737d454553e1e62109d8298ede5351178a4  #    10  2013-02-09 11:28:24  Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-2.6
>> git bisect good e1b28147f684af67bfac989756c27c19859d3d4e  #    10  2013-02-09 11:58:58  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/s390/linux
>> git bisect good 37820108f395032e850e400139d956561a043c26  #    10  2013-02-09 12:28:59  Merge tag 'fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
>> git bisect good 60541d778e536455970281de25b2476e01c03aef  #    10  2013-02-09 12:59:29  unicore32: switch to generic sys_execve()
>> git bisect good 403f43c937d24832b18524f65415c0bbba6b5064  #    10  2013-02-09 13:29:53  team: bcast: convert return value of team_dev_queue_xmit() to bool correctly
>> git bisect good e23739b4ade80a3a7f87198f008f6c44a7cbc9fd  #    10  2013-02-09 14:00:15  Merge branch 'v4l_for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-media
>> git bisect  bad 455e987c0c2eb2c9045dc854559474cf41509965  #     0  2013-02-09 14:03:12  Merge branch 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>> git bisect good 50a53bbe1280839755cb120eef729ad150f644f9  #    10  2013-02-09 14:31:02  Merge branch 'akpm' (Fixes from Andrew)
>> git bisect good 31e06a42a34395111842707a85774151245447b7  #    10  2013-02-09 15:01:25  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/signal
>> git bisect good 97a13bf3fed11a7508d58b67515c4b83cce25540  #    10  2013-02-09 15:31:48  Merge tag 'perf-uapi-20121119' of git://git.infradead.org/users/dhowells/linux-headers into perf/urgent
>> git bisect good 8fdd78eeb11aeda018b22424f863344ef83a92d3  #    10  2013-02-09 16:02:24  Merge tag 'for-linus' of git://linux-c6x.org/git/projects/linux-c6x-upstreaming
>> git bisect good 7c17e486e865d616f0e37c7f7f0e4dcfab704cd8  #    10  2013-02-09 16:32:42  Merge branch 'x86/urgent' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>> git bisect good 7321090f6751c9987c26a8c81c63680d16a614d7  #    10  2013-02-09 17:03:13  perf kvm: Fix building perf kvm on non x86 arches
>> git bisect good fd6da696f38b00ffeae1185d6f0ec5d4ab3b472d  #    10  2013-02-09 17:33:37  Merge tag 'perf-urgent-for-mingo' of git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux into perf/urgent
>> git bisect good 7c17e486e865d616f0e37c7f7f0e4dcfab704cd8  #    30  2013-02-09 18:34:45  Merge branch 'x86/urgent' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>> git bisect good fd6da696f38b00ffeae1185d6f0ec5d4ab3b472d  #    30  2013-02-09 19:35:42  Merge tag 'perf-urgent-for-mingo' of git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux into perf/urgent
>> git bisect  bad e347c988b34344c5192c2c238ad1c4bae51e975b  #     0  2013-02-09 19:51:48  Add linux-next specific files for 20130208
> 
> Well, bug as added in commit 08433eff2d041b263c68306f6a6ccb4e1f75e196
> (net neigh: Optimize neighbor entry size calculation.)

Thanks.  I've sent a patch to fix this as a separate mail.

--yoshfuji
