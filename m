From: Brad Campbell <lists2009@fnarfbargle.com>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Date: Tue, 07 Jun 2011 23:15:38 +0800
Message-ID: <4DEE409A.205@fnarfbargle.com>
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
Received: from fnarfbargle.com ([93.93.131.224]:48735 "EHLO fnarfbargle.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753534Ab1FGPP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 11:15:56 -0400
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

Here is the remainder of the log from that bug that I managed to scrape=
=20
off the disk. Odd as usually the netconsole dies and so does the disk=20
subsystem. In this case it managed to get the log to disk.

[  543.040056]=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
[  543.040136] BUG ip_dst_cache: Padding overwritten.=20
0xffff8803e4217ffe-0xffff8803e4217fff
[  543.040194]=20
-----------------------------------------------------------------------=
------
[  543.040198]
[  543.040298] INFO: Slab 0xffffea000d9e74d0 objects=3D25 used=3D25 fp=3D=
0x=20
        (null) flags=3D0x8000000000004081
[  543.040364] Pid: 4576, comm: kworker/1:2 Not tainted 3.0.0-rc2 #1
[  543.040415] Call Trace:
[  543.040472]  [<ffffffff810b9c1d>] ? slab_err+0xad/0xd0
[  543.040528]  [<ffffffff8102e034>] ? check_preempt_wakeup+0xa4/0x160
[  543.040595]  [<ffffffff810ba206>] ? slab_pad_check+0x126/0x170
[  543.040650]  [<ffffffff8133045b>] ? dst_destroy+0x8b/0x110
[  543.040701]  [<ffffffff810ba29a>] ? check_slab+0x4a/0xc0
[  543.040753]  [<ffffffff810baf2d>] ? free_debug_processing+0x2d/0x250
[  543.040808]  [<ffffffff810bb27b>] ? __slab_free+0x12b/0x140
[  543.040862]  [<ffffffff810bbe99>] ? kmem_cache_free+0x99/0xa0
[  543.040915]  [<ffffffff8133045b>] ? dst_destroy+0x8b/0x110
[  543.040967]  [<ffffffff813307f6>] ? dst_gc_task+0x196/0x1f0
[  543.041021]  [<ffffffff8104e954>] ? queue_delayed_work_on+0x154/0x16=
0
[  543.041081]  [<ffffffff813066fe>] ? do_dbs_timer+0x20e/0x3d0
[  543.041133]  [<ffffffff81330660>] ? dst_alloc+0x180/0x180
[  543.041187]  [<ffffffff8104f28b>] ? process_one_work+0xfb/0x3b0
[  543.041242]  [<ffffffff8104f964>] ? worker_thread+0x144/0x3d0
[  543.041296]  [<ffffffff8102cc10>] ? __wake_up_common+0x50/0x80
[  543.041678]  [<ffffffff8104f820>] ? rescuer_thread+0x2e0/0x2e0
[  543.041729]  [<ffffffff8104f820>] ? rescuer_thread+0x2e0/0x2e0
[  543.041782]  [<ffffffff81053436>] ? kthread+0x96/0xa0
[  543.041835]  [<ffffffff813e1d14>] ? kernel_thread_helper+0x4/0x10
[  543.041890]  [<ffffffff810533a0>] ? kthread_worker_fn+0x120/0x120
[  543.041944]  [<ffffffff813e1d10>] ? gs_change+0xb/0xb
[  543.041993]  Padding 0xffff8803e4217f40:  5a 5a 5a 5a 5a 5a 5a 5a 5a=
=20
5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[  543.042718]  Padding 0xffff8803e4217f50:  5a 5a 5a 5a 5a 5a 5a 5a 5a=
=20
5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[  543.043433]  Padding 0xffff8803e4217f60:  5a 5a 5a 5a 5a 5a 5a 5a 5a=
=20
5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[  543.044155]  Padding 0xffff8803e4217f70:  5a 5a 5a 5a 5a 5a 5a 5a 5a=
=20
5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[  543.044866]  Padding 0xffff8803e4217f80:  5a 5a 5a 5a 5a 5a 5a 5a 5a=
=20
5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[  543.045590]  Padding 0xffff8803e4217f90:  5a 5a 5a 5a 5a 5a 5a 5a 5a=
=20
5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[  543.046311]  Padding 0xffff8803e4217fa0:  5a 5a 5a 5a 5a 5a 5a 5a 5a=
=20
5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[  543.047034]  Padding 0xffff8803e4217fb0:  5a 5a 5a 5a 5a 5a 5a 5a 5a=
=20
5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[  543.047755]  Padding 0xffff8803e4217fc0:  5a 5a 5a 5a 5a 5a 5a 5a 5a=
=20
5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[  543.048474]  Padding 0xffff8803e4217fd0:  5a 5a 5a 5a 5a 5a 5a 5a 5a=
=20
5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[  543.049203]  Padding 0xffff8803e4217fe0:  5a 5a 5a 5a 5a 5a 5a 5a 5a=
=20
5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[  543.049909]  Padding 0xffff8803e4217ff0:  5a 5a 5a 5a 5a 5a 5a 5a 5a=
=20
5a 5a 5a 5a 5a 00 00 ZZZZZZZZZZZZZZ..
[  543.050021] FIX ip_dst_cache: Restoring=20
0xffff8803e4217f40-0xffff8803e4217fff=3D0x5a
[  543.050021]
[  885.504318] br1: port 4(vnet2) entering forwarding state
[  885.504797] device vnet2 left promiscuous mode
[  885.504868] br1: port 4(vnet2) entering disabled state
[  885.847186] br1: port 3(vnet1) entering forwarding state
[  885.847667] device vnet1 left promiscuous mode
[  885.847740] br1: port 3(vnet1) entering disabled state
[  885.940042]=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
[  885.940122] BUG kmalloc-512: Object padding overwritten
[  885.940171]=20
-----------------------------------------------------------------------=
------
[  885.940175]
[  885.940273] INFO: 0xffff8803dc09322e-0xffff8803dc09322f. First byte=20
0x0 instead of 0x5a
[  885.940344] INFO: Allocated in qdisc_alloc+0x59/0x110 age=3D66496 cp=
u=3D2=20
pid=3D4948
[  885.940404] INFO: Freed in qdisc_alloc+0x49/0x110 age=3D66496 cpu=3D=
2=20
pid=3D4948
[  885.940457] INFO: Slab 0xffffea000d821f80 objects=3D28 used=3D21=20
fp=3D0xffff8803dc090b68 flags=3D0x8000000000004081
[  885.940519] INFO: Object 0xffff8803dc092fe8 @offset=3D12264=20
fp=3D0xffff8803dc092238
[  885.940523]
[  885.940618] Bytes b4 0xffff8803dc092fd8:  d3 e0 ff ff 00 00 00 00 5a=
=20
5a 5a 5a 5a 5a 5a 5a =C3=93=C3=A0=C3=BF=C3=BF....ZZZZZZZZ
[  885.941373]   Object 0xffff8803dc092fe8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.942120]   Object 0xffff8803dc092ff8:  00 00 00 00 00 00 00 00 70=
=20
0a 34 81 ff ff ff ff ........p.4.=C3=BF=C3=BF=C3=BF=C3=BF
[  885.942847]   Object 0xffff8803dc093008:  b0 08 34 81 ff ff ff ff 04=
=20
00 00 00 18 00 00 00 =C2=B0.4.=C3=BF=C3=BF=C3=BF=C3=BF........
[  885.943585]   Object 0xffff8803dc093018:  60 ac 5d 81 ff ff ff ff 00=
=20
00 00 00 00 00 00 00 `=C2=AC].=C3=BF=C3=BF=C3=BF=C3=BF........
[  885.944324]   Object 0xffff8803dc093028:  28 30 09 dc 03 88 ff ff 28=
=20
30 09 dc 03 88 ff ff (0.=C3=9C..=C3=BF=C3=BF(0.=C3=9C..=C3=BF=C3=BF
[  885.945071]   Object 0xffff8803dc093038:  00 00 00 00 ff ff ff ff 00=
=20
00 00 00 00 00 00 00 ....=C3=BF=C3=BF=C3=BF=C3=BF........
[  885.945794]   Object 0xffff8803dc093048:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.946530]   Object 0xffff8803dc093058:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.947281]   Object 0xffff8803dc093068:  98 f3 f9 0e 04 88 ff ff 00=
=20
00 00 00 00 00 00 00 .=C3=B3=C3=B9...=C3=BF=C3=BF........
[  885.948011]   Object 0xffff8803dc093078:  00 00 00 00 00 00 00 00 02=
=20
00 00 00 00 00 00 00 ................
[  885.948735]   Object 0xffff8803dc093088:  88 30 09 dc 03 88 ff ff 88=
=20
30 09 dc 03 88 ff ff .0.=C3=9C..=C3=BF=C3=BF.0.=C3=9C..=C3=BF=C3=BF
[  885.949483]   Object 0xffff8803dc093098:  00 00 00 00 bf bf 00 00 ca=
=20
29 01 00 00 00 00 00 ....=C2=BF=C2=BF..=C3=8A)......
[  885.950007]   Object 0xffff8803dc0930a8:  de 01 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 =C3=9E...............
[  885.950007]   Object 0xffff8803dc0930b8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc0930c8:  10 cd 13 e7 03 88 ff ff a0=
=20
13 34 81 ff ff ff ff .=C3=8D.=C3=A7..=C3=BF=C3=BF..4.=C3=BF=C3=BF=C3=BF=
=C3=BF
[  885.950007]   Object 0xffff8803dc0930d8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc0930e8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc0930f8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc093108:  08 31 09 dc 03 88 ff ff 08=
=20
31 09 dc 03 88 ff ff .1.=C3=9C..=C3=BF=C3=BF.1.=C3=9C..=C3=BF=C3=BF
[  885.950007]   Object 0xffff8803dc093118:  00 00 00 00 00 00 00 00 20=
=20
31 09 dc 03 88 ff ff .........1.=C3=9C..=C3=BF=C3=BF
[  885.950007]   Object 0xffff8803dc093128:  20 31 09 dc 03 88 ff ff 00=
=20
00 00 00 00 00 00 00 .1.=C3=9C..=C3=BF=C3=BF........
[  885.950007]   Object 0xffff8803dc093138:  38 31 09 dc 03 88 ff ff 38=
=20
31 09 dc 03 88 ff ff 81.=C3=9C..=C3=BF=C3=BF81.=C3=9C..=C3=BF=C3=BF
[  885.950007]   Object 0xffff8803dc093148:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc093158:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc093168:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc093178:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc093188:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc093198:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc0931a8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc0931b8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc0931c8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]   Object 0xffff8803dc0931d8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  885.950007]  Redzone 0xffff8803dc0931e8:  cc cc cc cc cc cc cc cc=20
                      =C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C
[  885.950007]  Padding 0xffff8803dc093228:  5a 5a 5a 5a 5a 5a 00 00=20
                      ZZZZZZ..
[  885.950007] Pid: 11, comm: rcuc1 Not tainted 3.0.0-rc2 #1
[  885.950007] Call Trace:
[  885.950007]  [<ffffffff810ba41d>] ? check_bytes_and_report+0x10d/0x1=
50
[  885.950007]  [<ffffffff810ba509>] ? check_object+0xa9/0x260
[  885.950007]  [<ffffffff81075a49>] ? __rcu_process_callbacks+0x119/0x=
340
[  885.950007]  [<ffffffff810bb033>] ? free_debug_processing+0x133/0x25=
0
[  885.950007]  [<ffffffff810bb27b>] ? __slab_free+0x12b/0x140
[  885.950007]  [<ffffffff81075a49>] ? __rcu_process_callbacks+0x119/0x=
340
[  885.950007]  [<ffffffff8107666b>] ? rcu_cpu_kthread+0x27b/0x3a0
[  885.950007]  [<ffffffff8102d5b9>] ? ttwu_do_wakeup+0x19/0xa0
[  885.950007]  [<ffffffff81074a80>] ? invoke_rcu_cpu_kthread+0x30/0x30
[  885.950007]  [<ffffffff810763f0>] ? rcu_check_callbacks+0x100/0x100
[  885.950007]  [<ffffffff810763f0>] ? rcu_check_callbacks+0x100/0x100
[  885.950007]  [<ffffffff81053436>] ? kthread+0x96/0xa0
[  885.950007]  [<ffffffff813e1d14>] ? kernel_thread_helper+0x4/0x10
[  885.950007]  [<ffffffff810533a0>] ? kthread_worker_fn+0x120/0x120
[  885.950007]  [<ffffffff813e1d10>] ? gs_change+0xb/0xb
[  885.950007] FIX kmalloc-512: Restoring=20
0xffff8803dc09322e-0xffff8803dc09322f=3D0x5a
[  885.950007]
[  886.050119]=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
[  886.050198] BUG kmalloc-512: Object padding overwritten
[  886.050247]=20
-----------------------------------------------------------------------=
------
[  886.050251]
[  886.050353] INFO: 0xffff8803dc091916-0xffff8803dc091917. First byte=20
0x0 instead of 0x5a
[  886.050451] INFO: Allocated in kvm_ioapic_init+0x3c/0xd0 [kvm]=20
age=3D66256 cpu=3D0 pid=3D5122
[  886.050517] INFO: Freed in __kfree_skb+0x11/0x90 age=3D66311 cpu=3D4=
 pid=3D5054
[  886.050568] INFO: Slab 0xffffea000d821f80 objects=3D28 used=3D17=20
fp=3D0xffff8803dc091488 flags=3D0x8000000000004081
[  886.050630] INFO: Object 0xffff8803dc0916d0 @offset=3D5840 fp=3D0x=20
    (null)
[  886.050634]
[  886.050726] Bytes b4 0xffff8803dc0916c0:  ea e4 00 00 01 00 00 00 5a=
=20
5a 5a 5a 5a 5a 5a 5a =C3=AA=C3=A4......ZZZZZZZZ
[  886.051451]   Object 0xffff8803dc0916d0:  00 00 c0 fe 00 00 00 00 3f=
=20
00 00 00 00 00 00 00 ..=C3=80=C3=BE....?.......
[  886.052183]   Object 0xffff8803dc0916e0:  00 08 00 00 00 00 00 00 00=
=20
00 01 00 00 00 00 00 ................
[  886.052898]   Object 0xffff8803dc0916f0:  00 00 01 00 00 00 00 00 00=
=20
00 01 00 00 00 00 00 ................
[  886.053613]   Object 0xffff8803dc091700:  00 00 01 00 00 00 00 00 00=
=20
00 01 00 00 00 00 00 ................
[  886.054325]   Object 0xffff8803dc091710:  00 00 01 00 00 00 00 00 00=
=20
00 01 00 00 00 00 00 ................
[  886.055032]   Object 0xffff8803dc091720:  00 00 01 00 00 00 00 00 00=
=20
00 01 00 00 00 00 00 ................
[  886.055743]   Object 0xffff8803dc091730:  00 00 01 00 00 00 00 00 00=
=20
00 01 00 00 00 00 00 ................
[  886.056462]   Object 0xffff8803dc091740:  00 00 01 00 00 00 00 00 00=
=20
00 01 00 00 00 00 00 ................
[  886.057177]   Object 0xffff8803dc091750:  00 00 01 00 00 00 00 00 00=
=20
00 01 00 00 00 00 00 ................
[  886.058210]   Object 0xffff8803dc091760:  00 00 01 00 00 00 00 00 00=
=20
00 01 00 00 00 00 00 ................
[  886.058957]   Object 0xffff8803dc091770:  00 00 01 00 00 00 00 00 00=
=20
00 01 00 00 00 00 00 ................
[  886.059667]   Object 0xffff8803dc091780:  00 00 01 00 00 00 00 00 00=
=20
00 01 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc091790:  00 00 01 00 00 00 00 00 00=
=20
00 01 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc0917a0:  00 00 01 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc0917b0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc0917c0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc0917d0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc0917e0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc0917f0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc091800:  01 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc091810:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc091820:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc091830:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc091840:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc091850:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc091860:  00 00 00 00 00 00 00 00 b0=
=20
80 10 a0 ff ff ff ff ........=C2=B0...=C3=BF=C3=BF=C3=BF=C3=BF
[  886.060104]   Object 0xffff8803dc091870:  00 00 df f5 03 88 ff ff 00=
=20
00 00 00 00 00 00 00 ..=C3=9F=C3=B5..=C3=BF=C3=BF........
[  886.060104]   Object 0xffff8803dc091880:  43 43 00 00 00 00 00 00 01=
=20
00 00 00 00 00 00 00 CC..............
[  886.060104]   Object 0xffff8803dc091890:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc0918a0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc0918b0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]   Object 0xffff8803dc0918c0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[  886.060104]  Redzone 0xffff8803dc0918d0:  cc cc cc cc cc cc cc cc=20
                      =C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C
[  886.060104]  Padding 0xffff8803dc091910:  5a 5a 5a 5a 5a 5a 00 00=20
                      ZZZZZZ..
[  886.060104] Pid: 7359, comm: qemu Not tainted 3.0.0-rc2 #1
[  886.060104] Call Trace:
[  886.060104]  [<ffffffff810ba41d>] ? check_bytes_and_report+0x10d/0x1=
50
[  886.060104]  [<ffffffff810ba509>] ? check_object+0xa9/0x260
[  886.060104]  [<ffffffffa00eb8bf>] ? kvm_arch_destroy_vm+0x2f/0x150 [=
kvm]
[  886.060104]  [<ffffffff810bb033>] ? free_debug_processing+0x133/0x25=
0
[  886.060104]  [<ffffffff810bb27b>] ? __slab_free+0x12b/0x140
[  886.060104]  [<ffffffffa00eb8bf>] ? kvm_arch_destroy_vm+0x2f/0x150 [=
kvm]
[  886.060104]  [<ffffffffa00e2dd9>] ? kvm_put_kvm+0xe9/0x130 [kvm]
[  886.060104]  [<ffffffffa00e3763>] ? kvm_vcpu_release+0x13/0x20 [kvm]
[  886.060104]  [<ffffffff810c65fd>] ? fput+0xdd/0x270
[  886.060104]  [<ffffffff810c2e1c>] ? filp_close+0x5c/0x90
[  886.060104]  [<ffffffff8103ae1d>] ? put_files_struct+0xcd/0x100
[  886.060104]  [<ffffffff8103ccc7>] ? do_exit+0x6d7/0x7e0
[  886.060104]  [<ffffffff8103ce20>] ? do_group_exit+0x50/0xc0
[  886.060104]  [<ffffffff81048914>] ? get_signal_to_deliver+0x1a4/0x3a=
0
[  886.060104]  [<ffffffff8100188a>] ? do_signal+0x8a/0x7d0
[  886.060104]  [<ffffffff81049148>] ? kill_pid_info+0x38/0x60
[  886.060104]  [<ffffffff810493e4>] ? sys_kill+0x94/0x1b0
[  886.060104]  [<ffffffff8100201d>] ? do_notify_resume+0x4d/0x70
[  886.060104]  [<ffffffff810c59c4>] ? sys_pread64+0x74/0xa0
[  886.060104]  [<ffffffff813e11db>] ? int_signal+0x12/0x17
[  886.060104] FIX kmalloc-512: Restoring=20
0xffff8803dc091916-0xffff8803dc091917=3D0x5a
[  886.060104]
[  926.148014] br1: port 6(vnet4) entering forwarding state
[  926.148385] device vnet4 left promiscuous mode
[  926.148457] br1: port 6(vnet4) entering disabled state
[  945.659523] br1: port 2(vnet0) entering forwarding state
[  945.660041] device vnet0 left promiscuous mode
[  945.660116] br1: port 2(vnet0) entering disabled state
[ 1121.085267] br1: port 5(vnet3) entering forwarding state
[ 1121.085783] device vnet3 left promiscuous mode
[ 1121.085860] br1: port 5(vnet3) entering disabled state
[ 1176.307099] nfsd: last server has exited, flushing export cache
[ 1176.430113]=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
[ 1176.430194] BUG kmalloc-512: Object padding overwritten
[ 1176.430199]=20
-----------------------------------------------------------------------=
------
[ 1176.430204]
[ 1176.430210] INFO: 0xffff8803f5df5b5e-0xffff8803f5df5b5f. First byte=20
0x0 instead of 0x5a
[ 1176.430225] INFO: Allocated in sock_alloc_send_pskb+0x1d0/0x320=20
age=3D93370 cpu=3D0 pid=3D5126
[ 1176.430234] INFO: Freed in __kfree_skb+0x11/0x90 age=3D93370 cpu=3D0=
 pid=3D4495
[ 1176.430240] INFO: Slab 0xffffea000ddc8d60 objects=3D28 used=3D0=20
fp=3D0xffff8803f5df76c0 flags=3D0x8000000000004080
[ 1176.430246] INFO: Object 0xffff8803f5df5918 @offset=3D6424=20
fp=3D0xffff8803f5df7908
[ 1176.430249]
[ 1176.430253] Bytes b4 0xffff8803f5df5908:  ab f0 ff ff 00 00 00 00 5a=
=20
5a 5a 5a 5a 5a 5a 5a =C2=AB=C3=B0=C3=BF=C3=BF....ZZZZZZZZ
[ 1176.430270]   Object 0xffff8803f5df5918:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430285]   Object 0xffff8803f5df5928:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430300]   Object 0xffff8803f5df5938:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430314]   Object 0xffff8803f5df5948:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430328]   Object 0xffff8803f5df5958:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430343]   Object 0xffff8803f5df5968:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430357]   Object 0xffff8803f5df5978:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430371]   Object 0xffff8803f5df5988:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430386]   Object 0xffff8803f5df5998:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430400]   Object 0xffff8803f5df59a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430414]   Object 0xffff8803f5df59b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430429]   Object 0xffff8803f5df59c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430443]   Object 0xffff8803f5df59d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430457]   Object 0xffff8803f5df59e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430471]   Object 0xffff8803f5df59f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430485]   Object 0xffff8803f5df5a08:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430500]   Object 0xffff8803f5df5a18:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430514]   Object 0xffff8803f5df5a28:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430528]   Object 0xffff8803f5df5a38:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430542]   Object 0xffff8803f5df5a48:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430557]   Object 0xffff8803f5df5a58:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430571]   Object 0xffff8803f5df5a68:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430585]   Object 0xffff8803f5df5a78:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430599]   Object 0xffff8803f5df5a88:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430614]   Object 0xffff8803f5df5a98:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430628]   Object 0xffff8803f5df5aa8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430642]   Object 0xffff8803f5df5ab8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430656]   Object 0xffff8803f5df5ac8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430671]   Object 0xffff8803f5df5ad8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430685]   Object 0xffff8803f5df5ae8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430699]   Object 0xffff8803f5df5af8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430714]   Object 0xffff8803f5df5b08:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk=C2=A5
[ 1176.430729]  Redzone 0xffff8803f5df5b18:  bb bb bb bb bb bb bb bb=20
                      =C2=BB=C2=BB=C2=BB=C2=BB=C2=BB=C2=BB=C2=BB=C2=BB
[ 1176.430742]  Padding 0xffff8803f5df5b58:  5a 5a 5a 5a 5a 5a 00 00=20
                      ZZZZZZ..
[ 1176.430758] Pid: 24, comm: rcuc4 Not tainted 3.0.0-rc2 #1
[ 1176.430762] Call Trace:
[ 1176.430774]  [<ffffffff810ba41d>] ? check_bytes_and_report+0x10d/0x1=
50
[ 1176.430782]  [<ffffffff810ba509>] ? check_object+0xa9/0x260
[ 1176.430789]  [<ffffffff810bac15>] ? init_object+0x85/0xa0
[ 1176.430795]  [<ffffffff810ba816>] ? __free_slab+0x156/0x180
[ 1176.430803]  [<ffffffff81075a49>] ? __rcu_process_callbacks+0x119/0x=
340
[ 1176.430810]  [<ffffffff8107666b>] ? rcu_cpu_kthread+0x27b/0x3a0
[ 1176.430818]  [<ffffffff8102d5b9>] ? ttwu_do_wakeup+0x19/0xa0
[ 1176.430825]  [<ffffffff81074a80>] ? invoke_rcu_cpu_kthread+0x30/0x30
[ 1176.430832]  [<ffffffff810763f0>] ? rcu_check_callbacks+0x100/0x100
[ 1176.430838]  [<ffffffff810763f0>] ? rcu_check_callbacks+0x100/0x100
[ 1176.430846]  [<ffffffff81053436>] ? kthread+0x96/0xa0
[ 1176.430855]  [<ffffffff813e1d14>] ? kernel_thread_helper+0x4/0x10
[ 1176.430863]  [<ffffffff810533a0>] ? kthread_worker_fn+0x120/0x120
[ 1176.430870]  [<ffffffff813e1d10>] ? gs_change+0xb/0xb
[ 1176.430876] FIX kmalloc-512: Restoring=20
0xffff8803f5df5b5e-0xffff8803f5df5b5f=3D0x5a
[ 1176.430879]
[ 1176.430897]=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
[ 1176.430902] BUG kmalloc-512: Object padding overwritten
[ 1176.430905]=20
-----------------------------------------------------------------------=
------
[ 1176.430909]
[ 1176.430912] INFO: 0xffff8803f5df6fe6-0xffff8803f5df6fe7. First byte=20
0x0 instead of 0x5a
[ 1176.430921] INFO: Allocated in sock_alloc_send_pskb+0x1d0/0x320=20
age=3D93370 cpu=3D0 pid=3D5126
[ 1176.430928] INFO: Freed in __kfree_skb+0x11/0x90 age=3D93370 cpu=3D0=
 pid=3D4495
[ 1176.430935] INFO: Slab 0xffffea000ddc8d60 objects=3D28 used=3D0=20
fp=3D0xffff8803f5df76c0 flags=3D0x8000000000004080
[ 1176.430940] INFO: Object 0xffff8803f5df6da0 @offset=3D11680=20
fp=3D0xffff8803f5df5488
[ 1176.430943]
[ 1176.430946] Bytes b4 0xffff8803f5df6d90:  cd 7a 00 00 01 00 00 00 5a=
=20
5a 5a 5a 5a 5a 5a 5a =C3=8Dz......ZZZZZZZZ
[ 1176.430962]   Object 0xffff8803f5df6da0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430977]   Object 0xffff8803f5df6db0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.430992]   Object 0xffff8803f5df6dc0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431006]   Object 0xffff8803f5df6dd0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431021]   Object 0xffff8803f5df6de0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431036]   Object 0xffff8803f5df6df0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431050]   Object 0xffff8803f5df6e00:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431065]   Object 0xffff8803f5df6e10:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431080]   Object 0xffff8803f5df6e20:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431094]   Object 0xffff8803f5df6e30:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431109]   Object 0xffff8803f5df6e40:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431124]   Object 0xffff8803f5df6e50:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431138]   Object 0xffff8803f5df6e60:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431153]   Object 0xffff8803f5df6e70:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431168]   Object 0xffff8803f5df6e80:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431182]   Object 0xffff8803f5df6e90:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431197]   Object 0xffff8803f5df6ea0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431213]   Object 0xffff8803f5df6eb0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431228]   Object 0xffff8803f5df6ec0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431243]   Object 0xffff8803f5df6ed0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431258]   Object 0xffff8803f5df6ee0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431273]   Object 0xffff8803f5df6ef0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431287]   Object 0xffff8803f5df6f00:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431303]   Object 0xffff8803f5df6f10:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431317]   Object 0xffff8803f5df6f20:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431332]   Object 0xffff8803f5df6f30:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431346]   Object 0xffff8803f5df6f40:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431361]   Object 0xffff8803f5df6f50:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431376]   Object 0xffff8803f5df6f60:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431391]   Object 0xffff8803f5df6f70:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431405]   Object 0xffff8803f5df6f80:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1176.431420]   Object 0xffff8803f5df6f90:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk=C2=A5
[ 1176.431435]  Redzone 0xffff8803f5df6fa0:  bb bb bb bb bb bb bb bb=20
                      =C2=BB=C2=BB=C2=BB=C2=BB=C2=BB=C2=BB=C2=BB=C2=BB
[ 1176.431448]  Padding 0xffff8803f5df6fe0:  5a 5a 5a 5a 5a 5a 00 00=20
                      ZZZZZZ..
[ 1176.431463] Pid: 24, comm: rcuc4 Not tainted 3.0.0-rc2 #1
[ 1176.431467] Call Trace:
[ 1176.431474]  [<ffffffff810ba41d>] ? check_bytes_and_report+0x10d/0x1=
50
[ 1176.431481]  [<ffffffff810ba509>] ? check_object+0xa9/0x260
[ 1176.431487]  [<ffffffff810bac15>] ? init_object+0x85/0xa0
[ 1176.431494]  [<ffffffff810ba816>] ? __free_slab+0x156/0x180
[ 1176.431501]  [<ffffffff81075a49>] ? __rcu_process_callbacks+0x119/0x=
340
[ 1176.431508]  [<ffffffff8107666b>] ? rcu_cpu_kthread+0x27b/0x3a0
[ 1176.431515]  [<ffffffff8102d5b9>] ? ttwu_do_wakeup+0x19/0xa0
[ 1176.431522]  [<ffffffff81074a80>] ? invoke_rcu_cpu_kthread+0x30/0x30
[ 1176.431529]  [<ffffffff810763f0>] ? rcu_check_callbacks+0x100/0x100
[ 1176.431535]  [<ffffffff810763f0>] ? rcu_check_callbacks+0x100/0x100
[ 1176.431543]  [<ffffffff81053436>] ? kthread+0x96/0xa0
[ 1176.431550]  [<ffffffff813e1d14>] ? kernel_thread_helper+0x4/0x10
[ 1176.431558]  [<ffffffff810533a0>] ? kthread_worker_fn+0x120/0x120
[ 1176.431565]  [<ffffffff813e1d10>] ? gs_change+0xb/0xb
[ 1176.431571] FIX kmalloc-512: Restoring=20
0xffff8803f5df6fe6-0xffff8803f5df6fe7=3D0x5a
[ 1176.431574]
[ 1179.773660]=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
[ 1179.773742] BUG kmalloc-1024: Object padding overwritten
[ 1179.773792]=20
-----------------------------------------------------------------------=
------
[ 1179.773796]
[ 1179.773901] INFO: 0xffff8803e430e6be-0xffff8803e430e6bf. First byte=20
0x0 instead of 0x5a
[ 1179.773972] INFO: Allocated in tty_buffer_request_room+0xcc/0x1a0=20
age=3D93277 cpu=3D1 pid=3D5109
[ 1179.774042] INFO: Freed in __blockdev_direct_IO+0xa16/0xa90 age=3D93=
277=20
cpu=3D5 pid=3D5146
[ 1179.774102] INFO: Slab 0xffffea000d9ea9c0 objects=3D29 used=3D14=20
fp=3D0xffff8803e430d9e8 flags=3D0x8000000000004081
[ 1179.774163] INFO: Object 0xffff8803e430e278 @offset=3D25208=20
fp=3D0xffff8803e4309df8
[ 1179.774166]
[ 1179.774260] Bytes b4 0xffff8803e430e268:  a5 57 01 00 01 00 00 00 5a=
=20
5a 5a 5a 5a 5a 5a 5a =C2=A5W......ZZZZZZZZ
[ 1179.775297]   Object 0xffff8803e430e278:  08 eb 30 e4 03 88 ff ff a0=
=20
e2 30 e4 03 88 ff ff .=C3=AB0=C3=A4..=C3=BF=C3=BF.=C3=A20=C3=A4..=C3=BF=
=C3=BF
[ 1179.776003]   Object 0xffff8803e430e288:  a0 e3 30 e4 03 88 ff ff be=
=20
00 00 00 00 01 00 00 .=C3=A30=C3=A4..=C3=BF=C3=BF=C5=B8.......
[ 1179.776974]   Object 0xffff8803e430e298:  be 00 00 00 be 00 00 00 5b=
=20
20 20 20 20 32 2e 34 =C5=B8...=C5=B8...[....2.4
[ 1179.777656]   Object 0xffff8803e430e2a8:  31 30 32 34 36 5d 20 70 63=
=20
69 20 30 30 30 30 3a 10246].pci.0000:
[ 1179.778609]   Object 0xffff8803e430e2b8:  30 30 3a 31 34 2e 34 3a 20=
=20
20 20 62 72 69 64 67 00:14.4:...bridg
[ 1179.779289]   Object 0xffff8803e430e2c8:  65 20 77 69 6e 64 6f 77 20=
=20
5b 69 6f 20 20 30 78 e.window.[io..0x
[ 1179.779976]   Object 0xffff8803e430e2d8:  30 64 30 30 2d 30 78 66 66=
=20
66 66 5d 20 28 73 75 0d00-0xffff].(su
[ 1179.780327]   Object 0xffff8803e430e2e8:  62 74 72 61 63 74 69 76 65=
=20
20 64 65 63 6f 64 65 btractive.decode
[ 1179.780327]   Object 0xffff8803e430e2f8:  29 0d 0a 5b 20 20 20 20 32=
=20
2e 34 31 30 32 34 38 )..[....2.410248
[ 1179.780327]   Object 0xffff8803e430e308:  5d 20 70 63 69 20 30 30 30=
=20
30 3a 30 30 3a 31 34 ].pci.0000:00:14
[ 1179.780327]   Object 0xffff8803e430e318:  2e 34 3a 20 20 20 62 72 69=
=20
64 67 65 20 77 69 6e .4:...bridge.win
[ 1179.780327]   Object 0xffff8803e430e328:  64 6f 77 20 5b 6d 65 6d 20=
=20
30 78 30 30 30 61 30 dow.[mem.0x000a0
[ 1179.780327]   Object 0xffff8803e430e338:  30 30 30 2d 30 78 30 30 30=
=20
62 66 66 66 66 5d 20 000-0x000bffff].
[ 1179.780327]   Object 0xffff8803e430e348:  28 73 75 62 74 72 61 63 74=
=20
69 76 65 20 64 65 63 (subtractive.dec
[ 1179.780327]   Object 0xffff8803e430e358:  6f 64 65 29 0d 0a 32 30 5d=
=20
20 78 48 43 49 20 78 ode)..20].xHCI.x
[ 1179.780327]   Object 0xffff8803e430e368:  68 63 69 5f 63 68 65 63 6b=
=20
5f 62 61 6e 64 77 69 hci_check_bandwi
[ 1179.780327]   Object 0xffff8803e430e378:  64 74 68 20 63 61 6c 6c 65=
=20
64 20 66 6f 72 20 72 dth.called.for.r
[ 1179.780327]   Object 0xffff8803e430e388:  6f 6f 74 20 68 75 62 0d 0a=
=20
0d 0a 0d 0a 0d 0a 0d oot.hub.........
[ 1179.780327]   Object 0xffff8803e430e398:  0a 30 30 0d 0a 0d 0a 0a 00=
=20
00 00 00 00 00 00 00 .00.............
[ 1179.780327]   Object 0xffff8803e430e3a8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e3b8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e3c8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e3d8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e3e8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e3f8:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e408:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e418:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e428:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e438:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e448:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e458:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e468:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e478:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e488:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1179.780327]   Object 0xffff8803e430e498:  00 00 00 00 00 00 00 00 6b=
=20
6b 6b 6b 6b 6b 6b 6b ........kkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e4a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e4b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e4c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e4d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e4e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e4f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e508:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e518:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e528:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e538:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e548:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e558:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e568:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e578:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e588:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e598:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e5a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e5b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e5c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e5d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e5e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e5f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e608:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e618:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e628:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e638:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e648:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e658:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1179.780327]   Object 0xffff8803e430e668:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk=C2=A5
[ 1179.780327]  Redzone 0xffff8803e430e678:  cc cc cc cc cc cc cc cc=20
                      =C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C
[ 1179.780327]  Padding 0xffff8803e430e6b8:  5a 5a 5a 5a 5a 5a 00 00=20
                      ZZZZZZ..
[ 1179.780327] Pid: 2212, comm: kworker/5:2 Not tainted 3.0.0-rc2 #1
[ 1179.780327] Call Trace:
[ 1179.780327]  [<ffffffff810ba41d>] ? check_bytes_and_report+0x10d/0x1=
50
[ 1179.780327]  [<ffffffff810ba509>] ? check_object+0xa9/0x260
[ 1179.780327]  [<ffffffff8125acf7>] ? tty_buffer_free_all+0x47/0x70
[ 1179.780327]  [<ffffffff810bb033>] ? free_debug_processing+0x133/0x25=
0
[ 1179.780327]  [<ffffffff810bb27b>] ? __slab_free+0x12b/0x140
[ 1179.780327]  [<ffffffff81254c70>] ? free_tty_struct+0x30/0x30
[ 1179.780327]  [<ffffffff8125acf7>] ? tty_buffer_free_all+0x47/0x70
[ 1179.780327]  [<ffffffff81254c66>] ? free_tty_struct+0x26/0x30
[ 1179.780327]  [<ffffffff8104f28b>] ? process_one_work+0xfb/0x3b0
[ 1179.780327]  [<ffffffff8104f964>] ? worker_thread+0x144/0x3d0
[ 1179.780327]  [<ffffffff8102cc10>] ? __wake_up_common+0x50/0x80
[ 1179.780327]  [<ffffffff8104f820>] ? rescuer_thread+0x2e0/0x2e0
[ 1179.780327]  [<ffffffff8104f820>] ? rescuer_thread+0x2e0/0x2e0
[ 1179.780327]  [<ffffffff81053436>] ? kthread+0x96/0xa0
[ 1179.780327]  [<ffffffff813e1d14>] ? kernel_thread_helper+0x4/0x10
[ 1179.780327]  [<ffffffff810533a0>] ? kthread_worker_fn+0x120/0x120
[ 1179.780327]  [<ffffffff813e1d10>] ? gs_change+0xb/0xb
[ 1179.780327] FIX kmalloc-1024: Restoring=20
0xffff8803e430e6be-0xffff8803e430e6bf=3D0x5a
[ 1179.780327]
[ 1180.826212]=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
[ 1180.826289] BUG kmalloc-1024: Object padding overwritten
[ 1180.826338]=20
-----------------------------------------------------------------------=
------
[ 1180.826341]
[ 1180.826439] INFO: 0xffff8804097a9566-0xffff8804097a9567. First byte=20
0x0 instead of 0x5a
[ 1180.826505] INFO: Allocated in tty_buffer_request_room+0xcc/0x1a0=20
age=3D69291 cpu=3D0 pid=3D5978
[ 1180.826567] INFO: Freed in __blockdev_direct_IO+0xa16/0xa90 age=3D80=
371=20
cpu=3D5 pid=3D5713
[ 1180.826626] INFO: Slab 0xffffea000e212cc0 objects=3D29 used=3D3=20
fp=3D0xffff8804097a8890 flags=3D0x8000000000004081
[ 1180.826686] INFO: Object 0xffff8804097a9120 @offset=3D4384=20
fp=3D0xffff8804097a8890
[ 1180.826689]
[ 1180.826781] Bytes b4 0xffff8804097a9110:  91 48 01 00 01 00 00 00 5a=
=20
5a 5a 5a 5a 5a 5a 5a .H......ZZZZZZZZ
[ 1180.827478]   Object 0xffff8804097a9120:  30 de 70 fc 03 88 ff ff 48=
=20
91 7a 09 04 88 ff ff 0=C3=9Ep=C3=BC..=C3=BF=C3=BFH.z...=C3=BF=C3=BF
[ 1180.828179]   Object 0xffff8804097a9130:  48 92 7a 09 04 88 ff ff ce=
=20
00 00 00 00 01 00 00 H.z...=C3=BF=C3=BF=C3=8E.......
[ 1180.829149]   Object 0xffff8804097a9140:  ce 00 00 00 ce 00 00 00 5b=
=20
20 20 20 20 32 2e 33 =C3=8E...=C3=8E...[....2.3
[ 1180.830162]   Object 0xffff8804097a9150:  32 31 31 35 36 5d 20 70 63=
=20
69 20 30 30 30 30 3a 21156].pci.0000:
[ 1180.831118]   Object 0xffff8804097a9160:  30 30 3a 31 33 2e 30 3a 20=
=20
5b 31 30 30 32 3a 34 00:13.0:.[1002:4
[ 1180.831796]   Object 0xffff8804097a9170:  33 39 37 5d 20 74 79 70 65=
=20
20 30 20 63 6c 61 73 397].type.0.clas
[ 1180.832492]   Object 0xffff8804097a9180:  73 20 30 78 30 30 30 63 30=
=20
33 0d 0a 5b 20 20 20 s.0x000c03..[...
[ 1180.833482]   Object 0xffff8804097a9190:  20 32 2e 33 32 31 31 36 36=
=20
5d 20 70 63 69 20 30 .2.321166].pci.0
[ 1180.834173]   Object 0xffff8804097a91a0:  30 30 30 3a 30 30 3a 31 33=
=20
2e 30 3a 20 72 65 67 000:00:13.0:.reg
[ 1180.835134]   Object 0xffff8804097a91b0:  20 31 30 3a 20 5b 6d 65 6d=
=20
20 30 78 66 65 31 66 .10:.[mem.0xfe1f
[ 1180.835240]   Object 0xffff8804097a91c0:  64 30 30 30 2d 30 78 66 65=
=20
31 66 64 66 66 66 5d d000-0xfe1fdfff]
[ 1180.835240]   Object 0xffff8804097a91d0:  0d 0a 5b 20 20 20 20 32 2e=
=20
33 32 31 32 31 38 5d ..[....2.321218]
[ 1180.835240]   Object 0xffff8804097a91e0:  20 70 63 69 20 30 30 30 30=
=20
3a 30 30 3a 31 33 2e .pci.0000:00:13.
[ 1180.835240]   Object 0xffff8804097a91f0:  32 3a 20 5b 31 30 30 32 3a=
=20
34 33 39 36 5d 20 74 2:.[1002:4396].t
[ 1180.835240]   Object 0xffff8804097a9200:  79 70 65 20 30 20 63 6c 61=
=20
73 73 20 30 78 30 30 ype.0.class.0x00
[ 1180.835240]   Object 0xffff8804097a9210:  30 63 30 33 0d 0a 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b 0c03..kkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9220:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9230:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9240:  6b 6b 6b 6b 6b 6b 6b 6b 00=
=20
00 00 00 00 00 00 00 kkkkkkkk........
[ 1180.835240]   Object 0xffff8804097a9250:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.835240]   Object 0xffff8804097a9260:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.835240]   Object 0xffff8804097a9270:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.835240]   Object 0xffff8804097a9280:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.835240]   Object 0xffff8804097a9290:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.835240]   Object 0xffff8804097a92a0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.835240]   Object 0xffff8804097a92b0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.835240]   Object 0xffff8804097a92c0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.835240]   Object 0xffff8804097a92d0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.835240]   Object 0xffff8804097a92e0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.835240]   Object 0xffff8804097a92f0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.835240]   Object 0xffff8804097a9300:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.835240]   Object 0xffff8804097a9310:  00 00 00 00 00 00 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b ......kkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9320:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9330:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9340:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9350:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9360:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9370:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9380:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9390:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a93a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a93b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a93c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a93d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a93e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a93f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9400:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9410:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9420:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9430:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9440:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9450:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9460:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9470:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9480:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9490:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a94a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a94b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a94c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a94d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a94e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a94f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9500:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.835240]   Object 0xffff8804097a9510:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk=C2=A5
[ 1180.835240]  Redzone 0xffff8804097a9520:  cc cc cc cc cc cc cc cc=20
                      =C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C
[ 1180.835240]  Padding 0xffff8804097a9560:  5a 5a 5a 5a 5a 5a 00 00=20
                      ZZZZZZ..
[ 1180.835240] Pid: 8295, comm: kworker/5:0 Not tainted 3.0.0-rc2 #1
[ 1180.835240] Call Trace:
[ 1180.835240]  [<ffffffff810ba41d>] ? check_bytes_and_report+0x10d/0x1=
50
[ 1180.835240]  [<ffffffff810ba509>] ? check_object+0xa9/0x260
[ 1180.835240]  [<ffffffff8125acf7>] ? tty_buffer_free_all+0x47/0x70
[ 1180.835240]  [<ffffffff810bb033>] ? free_debug_processing+0x133/0x25=
0
[ 1180.835240]  [<ffffffff810bb27b>] ? __slab_free+0x12b/0x140
[ 1180.835240]  [<ffffffff81254c70>] ? free_tty_struct+0x30/0x30
[ 1180.835240]  [<ffffffff8125acf7>] ? tty_buffer_free_all+0x47/0x70
[ 1180.835240]  [<ffffffff81254c66>] ? free_tty_struct+0x26/0x30
[ 1180.835240]  [<ffffffff8104f28b>] ? process_one_work+0xfb/0x3b0
[ 1180.835240]  [<ffffffff8104f964>] ? worker_thread+0x144/0x3d0
[ 1180.835240]  [<ffffffff8102cc10>] ? __wake_up_common+0x50/0x80
[ 1180.835240]  [<ffffffff8104f820>] ? rescuer_thread+0x2e0/0x2e0
[ 1180.835240]  [<ffffffff8104f820>] ? rescuer_thread+0x2e0/0x2e0
[ 1180.835240]  [<ffffffff81053436>] ? kthread+0x96/0xa0
[ 1180.835240]  [<ffffffff813e1d14>] ? kernel_thread_helper+0x4/0x10
[ 1180.835240]  [<ffffffff810533a0>] ? kthread_worker_fn+0x120/0x120
[ 1180.835240]  [<ffffffff813e1d10>] ? gs_change+0xb/0xb
[ 1180.835240] FIX kmalloc-1024: Restoring=20
0xffff8804097a9566-0xffff8804097a9567=3D0x5a
[ 1180.835240]
[ 1180.881652]=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
[ 1180.881713] BUG kmalloc-1024: Object padding overwritten
[ 1180.881760]=20
-----------------------------------------------------------------------=
------
[ 1180.881763]
[ 1180.881859] INFO: 0xffff8803fc70eb06-0xffff8803fc70eb07. First byte=20
0x0 instead of 0x5a
[ 1180.881920] INFO: Allocated in tty_buffer_request_room+0xcc/0x1a0=20
age=3D69297 cpu=3D0 pid=3D5978
[ 1180.881981] INFO: Freed in __blockdev_direct_IO+0xa16/0xa90 age=3D69=
384=20
cpu=3D5 pid=3D5146
[ 1180.882040] INFO: Slab 0xffffea000df389c0 objects=3D29 used=3D3=20
fp=3D0xffff8803fc70de30 flags=3D0x8000000000004081
[ 1180.882099] INFO: Object 0xffff8803fc70e6c0 @offset=3D26304=20
fp=3D0xffff8803fc70de30
[ 1180.882102]
[ 1180.882192] Bytes b4 0xffff8803fc70e6b0:  aa 40 01 00 01 00 00 00 5a=
=20
5a 5a 5a 5a 5a 5a 5a =C2=AA@......ZZZZZZZZ
[ 1180.882884]   Object 0xffff8803fc70e6c0:  68 95 6c fc 03 88 ff ff e8=
=20
e6 70 fc 03 88 ff ff h.l=C3=BC..=C3=BF=C3=BF=C3=A8=C3=A6p=C3=BC..=C3=BF=
=C3=BF
[ 1180.883583]   Object 0xffff8803fc70e6d0:  e8 e7 70 fc 03 88 ff ff 00=
=20
01 00 00 00 01 00 00 =C3=A8=C3=A7p=C3=BC..=C3=BF=C3=BF........
[ 1180.884542]   Object 0xffff8803fc70e6e0:  00 01 00 00 00 01 00 00 5b=
=20
20 20 20 20 32 2e 33 ........[....2.3
[ 1180.885223]   Object 0xffff8803fc70e6f0:  32 30 38 31 38 5d 20 70 63=
=20
69 20 30 30 30 30 3a 20818].pci.0000:
[ 1180.886169]   Object 0xffff8803fc70e700:  30 30 3a 30 34 2e 30 3a 20=
=20
50 4d 45 23 20 73 75 00:04.0:.PME#.su
[ 1180.886850]   Object 0xffff8803fc70e710:  70 70 6f 72 74 65 64 20 66=
=20
72 6f 6d 20 44 30 20 pported.from.D0.
[ 1180.887535]   Object 0xffff8803fc70e720:  44 33 68 6f 74 20 44 33 63=
=20
6f 6c 64 0d 0a 5b 20 D3hot.D3cold..[.
[ 1180.888848]   Object 0xffff8803fc70e730:  20 20 20 32 2e 33 32 30 38=
=20
32 30 5d 20 70 63 69 ...2.320820].pci
[ 1180.889537]   Object 0xffff8803fc70e740:  20 30 30 30 30 3a 30 30 3a=
=20
30 34 2e 30 3a 20 50 .0000:00:04.0:.P
[ 1180.890481]   Object 0xffff8803fc70e750:  4d 45 23 20 64 69 73 61 62=
=20
6c 65 64 0d 0a 5b 20 ME#.disabled..[.
[ 1180.891161]   Object 0xffff8803fc70e760:  20 20 20 32 2e 33 32 30 38=
=20
33 36 5d 20 70 63 69 ...2.320836].pci
[ 1180.891365]   Object 0xffff8803fc70e770:  20 30 30 30 30 3a 30 30 3a=
=20
30 39 2e 30 3a 20 5b .0000:00:09.0:.[
[ 1180.891365]   Object 0xffff8803fc70e780:  31 30 32 32 3a 39 36 30 38=
=20
5d 20 74 79 70 65 20 1022:9608].type.
[ 1180.891365]   Object 0xffff8803fc70e790:  31 20 63 6c 61 73 73 20 30=
=20
78 30 30 30 36 30 34 1.class.0x000604
[ 1180.891365]   Object 0xffff8803fc70e7a0:  0d 0a 5b 20 20 20 20 32 2e=
=20
33 32 30 38 35 35 5d ..[....2.320855]
[ 1180.891365]   Object 0xffff8803fc70e7b0:  20 70 63 69 20 30 30 30 30=
=20
3a 30 30 3a 30 39 2e .pci.0000:00:09.
[ 1180.891365]   Object 0xffff8803fc70e7c0:  30 3a 20 50 4d 45 23 20 73=
=20
75 70 70 6f 72 74 65 0:.PME#.supporte
[ 1180.891365]   Object 0xffff8803fc70e7d0:  64 20 66 72 6f 6d 20 44 30=
=20
20 44 33 68 6f 74 20 d.from.D0.D3hot.
[ 1180.891365]   Object 0xffff8803fc70e7e0:  44 33 63 6f 6c 64 0d 0a 00=
=20
00 00 00 00 00 00 00 D3cold..........
[ 1180.891365]   Object 0xffff8803fc70e7f0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e800:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e810:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e820:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e830:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e840:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e850:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e860:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e870:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e880:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e890:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e8a0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e8b0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e8c0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e8d0:  00 00 00 00 00 00 00 00 00=
=20
00 00 00 00 00 00 00 ................
[ 1180.891365]   Object 0xffff8803fc70e8e0:  00 00 00 00 00 00 00 00 6b=
=20
6b 6b 6b 6b 6b 6b 6b ........kkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e8f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e900:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e910:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e920:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e930:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e940:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e950:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e960:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e970:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e980:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e990:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e9a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e9b0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e9c0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e9d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e9e0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70e9f0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70ea00:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70ea10:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70ea20:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70ea30:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70ea40:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70ea50:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70ea60:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70ea70:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70ea80:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70ea90:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70eaa0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[ 1180.891365]   Object 0xffff8803fc70eab0:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
=20
6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk=C2=A5
[ 1180.891365]  Redzone 0xffff8803fc70eac0:  cc cc cc cc cc cc cc cc=20
                      =C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C=C3=8C
[ 1180.891365]  Padding 0xffff8803fc70eb00:  5a 5a 5a 5a 5a 5a 00 00=20
                      ZZZZZZ..
[ 1180.891365] Pid: 8295, comm: kworker/5:0 Not tainted 3.0.0-rc2 #1
[ 1180.891365] Call Trace:
[ 1180.891365]  [<ffffffff810ba41d>] ? check_bytes_and_report+0x10d/0x1=
50
[ 1180.891365]  [<ffffffff810ba509>] ? check_object+0xa9/0x260
[ 1180.891365]  [<ffffffff8125acf7>] ? tty_buffer_free_all+0x47/0x70
[ 1180.891365]  [<ffffffff810bb033>] ? free_debug_processing+0x133/0x25=
0
[ 1180.891365]  [<ffffffff810bb27b>] ? __slab_free+0x12b/0x140
[ 1180.891365]  [<ffffffff81254c70>] ? free_tty_struct+0x30/0x30
[ 1180.891365]  [<ffffffff8125acf7>] ? tty_buffer_free_all+0x47/0x70
[ 1180.891365]  [<ffffffff81254c66>] ? free_tty_struct+0x26/0x30
[ 1180.891365]  [<ffffffff8104f28b>] ? process_one_work+0xfb/0x3b0
[ 1180.891365]  [<ffffffff8104f964>] ? worker_thread+0x144/0x3d0
[ 1180.891365]  [<ffffffff8102cc10>] ? __wake_up_common+0x50/0x80
[ 1180.891365]  [<ffffffff8104f820>] ? rescuer_thread+0x2e0/0x2e0
[ 1180.891365]  [<ffffffff8104f820>] ? rescuer_thread+0x2e0/0x2e0
[ 1180.891365]  [<ffffffff81053436>] ? kthread+0x96/0xa0
[ 1180.891365]  [<ffffffff813e1d14>] ? kernel_thread_helper+0x4/0x10
[ 1180.891365]  [<ffffffff810533a0>] ? kthread_worker_fn+0x120/0x120
[ 1180.891365]  [<ffffffff813e1d10>] ? gs_change+0xb/0xb
[ 1180.891365] FIX kmalloc-1024: Restoring=20
0xffff8803fc70eb06-0xffff8803fc70eb07=3D0x5a
[ 1180.891365]
