From: Brad Campbell <lists2009@fnarfbargle.com>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Date: Sat, 20 Aug 2011 21:16:39 +0800
Message-ID: <4E4FB3B7.4040501@fnarfbargle.com>
References: <20110601011527.GN19505@random.random>	 <alpine.LSU.2.00.1105312120530.22808@sister.anvils>	 <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com>	 <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com>	 <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com>	 <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com>	 <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>	 <4DEB3AE4.8040700@redhat.com>  <4DEB8872.2060801@fnarfbargle.com>	 <1307391746.2642.11.camel@edumazet-laptop>	 <4DEE273F.7090402@fnarfbargle.com> <1307453874.3091.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, CaT <cat@zip.com.au>,
	Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fnarfbargle.com ([93.93.131.67]:36603 "EHLO fnarfbargle.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751761Ab1HTNyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Aug 2011 09:54:55 -0400
In-Reply-To: <1307453874.3091.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/06/11 21:37, Eric Dumazet wrote:
> Le mardi 07 juin 2011 =C3=A0 21:27 +0800, Brad Campbell a =C3=A9crit =
:
>> On 07/06/11 04:22, Eric Dumazet wrote:
>>
>>> Could you please try latest linux-2.6 tree ?
>>>
>>> We fixed many networking bugs that could explain your crash.
>>>
>>>
>>>
>>>
>>
>> No good I'm afraid.
>>
>> [  543.040056]
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>> [  543.040136] BUG ip_dst_cache: Padding overwritten.
>> 0xffff8803e4217ffe-0xffff8803e4217fff
>> [  543.040194]
>
> Thats pretty strange : These are the last two bytes of a page, set to
> 0x0000 (a 16 bit value)
>
> There is no way a dst field could actually sit on this location (its =
a
> padding), since a dst is a bit less than 256 bytes (0xe8), and each
> entry is aligned on a 64byte address.
>
> grep dst /proc/slabinfo
>
> ip_dst_cache       32823  62944    256   32    2 : tunables    0    0
> 0 : slabdata   1967   1967      0
>
> sizeof(struct rtable)=3D0xe8
>
>
>> --------------------------------------------------------------------=
---------
>> [  543.040198]
>> [  543.040298] INFO: Slab 0xffffea000d9e74d0 objects=3D25 used=3D25 =
fp=3D0x
>>          (null) flags=3D0x8000000000004081
>> [  543.040364] Pid: 4576, comm: kworker/1:2 Not tainted 3.0.0-rc2 #1
>> [  543.040415] Call Trace:
>> [  543.040472]  [<ffffffff810b9c1d>] ? slab_err+0xad/0xd0
>> [  543.040528]  [<ffffffff8102e034>] ? check_preempt_wakeup+0xa4/0x1=
60
>> [  543.040595]  [<ffffffff810ba206>] ? slab_pad_check+0x126/0x170
>> [  543.040650]  [<ffffffff8133045b>] ? dst_destroy+0x8b/0x110
>> [  543.040701]  [<ffffffff810ba29a>] ? check_slab+0x4a/0xc0
>> [  543.040753]  [<ffffffff810baf2d>] ? free_debug_processing+0x2d/0x=
250
>> [  543.040808]  [<ffffffff810bb27b>] ? __slab_free+0x12b/0x140
>> [  543.040862]  [<ffffffff810bbe99>] ? kmem_cache_free+0x99/0xa0
>> [  543.040915]  [<ffffffff8133045b>] ? dst_destroy+0x8b/0x110
>> [  543.040967]  [<ffffffff813307f6>] ? dst_gc_task+0x196/0x1f0
>> [  543.041021]  [<ffffffff8104e954>] ? queue_delayed_work_on+0x154/0=
x160
>> [  543.041081]  [<ffffffff813066fe>] ? do_dbs_timer+0x20e/0x3d0
>> [  543.041133]  [<ffffffff81330660>] ? dst_alloc+0x180/0x180
>> [  543.041187]  [<ffffffff8104f28b>] ? process_one_work+0xfb/0x3b0
>> [  543.041242]  [<ffffffff8104f964>] ? worker_thread+0x144/0x3d0
>> [  543.041296]  [<ffffffff8102cc10>] ? __wake_up_common+0x50/0x80
>> [  543.041678]  [<ffffffff8104f820>] ? rescuer_thread+0x2e0/0x2e0
>> [  543.041729]  [<ffffffff8104f820>] ? rescuer_thread+0x2e0/0x2e0
>> [  543.041782]  [<ffffffff81053436>] ? kthread+0x96/0xa0
>> [  543.041835]  [<ffffffff813e1d14>] ? kernel_thread_helper+0x4/0x10
>> [  543.041890]  [<ffffffff810533a0>] ? kthread_worker_fn+0x120/0x120
>> [  543.041944]  [<ffffffff813e1d10>] ? gs_change+0xb/0xb
>> [  543.041993]  Padding 0xffff8803e4217f40:  5a 5a 5a 5a 5a 5a 5a 5a=
 5a
>> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
>> [  543.042718]  Padding 0xffff8803e4217f50:  5a 5a 5a 5a 5a 5a 5a 5a=
 5a
>> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
>> [  543.043433]  Padding 0xffff8803e4217f60:  5a 5a 5a 5a 5a 5a 5a 5a=
 5a
>> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
>> [  543.044155]  Padding 0xffff8803e4217f70:  5a 5a 5a 5a 5a 5a 5a 5a=
 5a
>> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
>> [  543.044866]  Padding 0xffff8803e4217f80:  5a 5a 5a 5a 5a 5a 5a 5a=
 5a
>> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
>> [  543.045590]  Padding 0xffff8803e4217f90:  5a 5a 5a 5a 5a 5a 5a 5a=
 5a
>> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
>> [  543.046311]  Padding 0xffff8803e4217fa0:  5a 5a 5a 5a 5a 5a 5a 5a=
 5a
>> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
>> [  543.047034]  Padding 0xffff8803e4217fb0:  5a 5a 5a 5a 5a 5a 5a 5a=
 5a
>> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
>> [  543.047755]  Padding 0xffff8803e4217fc0:  5a 5a 5a 5a 5a 5a 5a 5a=
 5a
>> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
>> [  543.048474]  Padding 0xffff8803e4217fd0:  5a 5a 5a 5a 5a 5a 5a 5a=
 5a
>> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
>> [  543.049203]  Padding 0xffff8803e4217fe0:  5a 5a 5a 5a 5a 5a 5a 5a=
 5a
>> 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
>> [  543.049909]  Padding 0xffff8803e4217ff0:  5a 5a 5a 5a 5a 5a 5a 5a=
 5a
>> 5a 5a 5a 5a 5a 00 00 ZZZZZZZZZZZZZZ..
>> [  543.050021] FIX ip_dst_cache: Restoring
>> 0xffff8803e4217f40-0xffff8803e4217fff=3D0x5a
>> [  543.050021]
>>
>> Dropped -mm, Hugh and Andrea from CC as this does not appear to be m=
m or
>> ksm related.
>>
>> I'll pare down the firewall and see if I can make it break easier wi=
th a
>> smaller test set.
>
> Hmm, not sure now :(
>
> Could you reproduce another bug please ?

I know this is an old one, but I recently purchased a second system to=20
allow me to test and bisect this off-line (the live system is too much=20
of a headache to bisect on).

brad@test:/raid10/src/linux-2.6$ git bisect log
git bisect start
# good: [9fe6206f400646a2322096b56c59891d530e8d51] Linux 2.6.35
git bisect good 9fe6206f400646a2322096b56c59891d530e8d51
# bad: [da5cabf80e2433131bf0ed8993abc0f7ea618c73] Linux 2.6.36-rc1
git bisect bad da5cabf80e2433131bf0ed8993abc0f7ea618c73
# bad: [0f477dd0851bdcee82923da66a7fc4a44cb1bc3d] Merge branch=20
'x86-cpu-for-linus' of=20
git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
git bisect bad 0f477dd0851bdcee82923da66a7fc4a44cb1bc3d
# bad: [3ff1c25927e3af61c6bf0e4ed959504058ae4565] phy/marvell: add=20
88ec048 support
git bisect bad 3ff1c25927e3af61c6bf0e4ed959504058ae4565
# good: [05318bc905467237d4aa68a701f6e92a2b332218] Merge branch 'master=
'=20
of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next=
-2.6
git bisect good 05318bc905467237d4aa68a701f6e92a2b332218
# bad: [2ba13ed678775195e8255b4e503c59d48b615bd8] Bluetooth: Remove=20
check for supported mode
git bisect bad 2ba13ed678775195e8255b4e503c59d48b615bd8
# bad: [1e2cfeef060fa0270f9a2d66b1218c12c05062e0] Revert "tc35815: fix=20
iomap leak"
git bisect bad 1e2cfeef060fa0270f9a2d66b1218c12c05062e0
# bad: [d9bed6bbd4f2a0120c93fed68605950651e1f225] isdn/gigaset: remove=20
EXPERIMENTAL tag from GIGASET_CAPI
git bisect bad d9bed6bbd4f2a0120c93fed68605950651e1f225
# bad: [d117b6665847084cfe8a44b870f771153e18991d] fealnx: Use the=20
instance of net_device_stats from net_device.
git bisect bad d117b6665847084cfe8a44b870f771153e18991d
# bad: [e490c1defec4236a6a131fe2d13bf7ba787c02f8] Merge branch 'master'=
=20
of git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6
git bisect bad e490c1defec4236a6a131fe2d13bf7ba787c02f8
# bad: [0a17d8c744e44617a3c22e7af68b4c5c9c1c5dba] ixgbe: use NETIF_F_LR=
O
git bisect bad 0a17d8c744e44617a3c22e7af68b4c5c9c1c5dba
# bad: [ede3ef0d940ef052466f42c849390b23c6859abc] igb: fix PHY config=20
access on 82580
git bisect bad ede3ef0d940ef052466f42c849390b23c6859abc
# good: [ee3cb6295144b0adfa75ccaca307643a6998b1e2] be2net: changes to=20
properly provide phy details
git bisect good ee3cb6295144b0adfa75ccaca307643a6998b1e2
# bad: [7475271004b66e9c22e1bb28f240a38c5d6fe76e] x86: Drop=20
CONFIG_MCORE2 check around setting of NET_IP_ALIGN
git bisect bad 7475271004b66e9c22e1bb28f240a38c5d6fe76e
brad@test:/raid10/src/linux-2.6$ git bisect log
git bisect start
# good: [9fe6206f400646a2322096b56c59891d530e8d51] Linux 2.6.35
git bisect good 9fe6206f400646a2322096b56c59891d530e8d51
# bad: [da5cabf80e2433131bf0ed8993abc0f7ea618c73] Linux 2.6.36-rc1
git bisect bad da5cabf80e2433131bf0ed8993abc0f7ea618c73
# bad: [0f477dd0851bdcee82923da66a7fc4a44cb1bc3d] Merge branch=20
'x86-cpu-for-linus' of=20
git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
git bisect bad 0f477dd0851bdcee82923da66a7fc4a44cb1bc3d
# bad: [3ff1c25927e3af61c6bf0e4ed959504058ae4565] phy/marvell: add=20
88ec048 support
git bisect bad 3ff1c25927e3af61c6bf0e4ed959504058ae4565
# good: [05318bc905467237d4aa68a701f6e92a2b332218] Merge branch 'master=
'=20
of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next=
-2.6
git bisect good 05318bc905467237d4aa68a701f6e92a2b332218
# bad: [2ba13ed678775195e8255b4e503c59d48b615bd8] Bluetooth: Remove=20
check for supported mode
git bisect bad 2ba13ed678775195e8255b4e503c59d48b615bd8
# bad: [1e2cfeef060fa0270f9a2d66b1218c12c05062e0] Revert "tc35815: fix=20
iomap leak"
git bisect bad 1e2cfeef060fa0270f9a2d66b1218c12c05062e0
# bad: [d9bed6bbd4f2a0120c93fed68605950651e1f225] isdn/gigaset: remove=20
EXPERIMENTAL tag from GIGASET_CAPI
git bisect bad d9bed6bbd4f2a0120c93fed68605950651e1f225
# bad: [d117b6665847084cfe8a44b870f771153e18991d] fealnx: Use the=20
instance of net_device_stats from net_device.
git bisect bad d117b6665847084cfe8a44b870f771153e18991d
# bad: [e490c1defec4236a6a131fe2d13bf7ba787c02f8] Merge branch 'master'=
=20
of git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6
git bisect bad e490c1defec4236a6a131fe2d13bf7ba787c02f8
# bad: [0a17d8c744e44617a3c22e7af68b4c5c9c1c5dba] ixgbe: use NETIF_F_LR=
O
git bisect bad 0a17d8c744e44617a3c22e7af68b4c5c9c1c5dba
# bad: [ede3ef0d940ef052466f42c849390b23c6859abc] igb: fix PHY config=20
access on 82580
git bisect bad ede3ef0d940ef052466f42c849390b23c6859abc
# good: [ee3cb6295144b0adfa75ccaca307643a6998b1e2] be2net: changes to=20
properly provide phy details
git bisect good ee3cb6295144b0adfa75ccaca307643a6998b1e2
# bad: [7475271004b66e9c22e1bb28f240a38c5d6fe76e] x86: Drop=20
CONFIG_MCORE2 check around setting of NET_IP_ALIGN
git bisect bad 7475271004b66e9c22e1bb28f240a38c5d6fe76e
brad@test:/raid10/src/linux-2.6$ git bisect good
7475271004b66e9c22e1bb28f240a38c5d6fe76e is the first bad commit
commit 7475271004b66e9c22e1bb28f240a38c5d6fe76e
Author: Alexander Duyck <alexander.h.duyck@intel.com>
Date:   Thu Jul 1 13:28:27 2010 +0000

     x86: Drop CONFIG_MCORE2 check around setting of NET_IP_ALIGN

     This patch removes the CONFIG_MCORE2 check from around=20
NET_IP_ALIGN.  It is
     based on a suggestion from Andi Kleen.  The assumption is that=20
there are
     not any x86 cores where unaligned access is really slow, and this=20
change
     would allow for a performance improvement to still exist on=20
configurations
     that are not necessarily optimized for Core 2.

     Cc: Andi Kleen <ak@linux.intel.com>
     Cc: Thomas Gleixner <tglx@linutronix.de>
     Cc: Ingo Molnar <mingo@redhat.com>
     Cc: "H. Peter Anvin" <hpa@zytor.com>
     Cc: x86@kernel.org
     Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
     Acked-by: H. Peter Anvin <hpa@zytor.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 5a15867789080a2f67a74b17c4422f85b7a9fb4a=20
b98769348bd765731ca3ff03b33764257e23226c M	arch

I can confirm this bug exists in the 3.0 kernel, however I'm unable to=20
reproduce it on todays git.

So anyone using netfilter, kvm and bridge on kernels between 2.6.36-rc1=
=20
and 3.0 may hit this bug, but it looks like it is fixed in the current=20
3.1-rc kernels.

