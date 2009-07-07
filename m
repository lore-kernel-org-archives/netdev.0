From: Emil S Tantilov <emils.tantilov@gmail.com>
Subject: Re: WARNING: at include/net/sock.h:417 udp_lib_unhash
Date: Mon, 6 Jul 2009 17:54:50 -0700
Message-ID: <bde4e1140907061754r1b158bf5w4bbf7b4dca06086@mail.gmail.com>
References: <EA929A9653AAE14F841771FB1DE5A1365F8AB77D05@rrsmsx501.amr.corp.intel.com>
	 <4A4C4F46.2070701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	NetDev <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Jiri Olsa <jolsa@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f202.google.com ([209.85.212.202]:40101 "EHLO
	mail-vw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbZGGAys convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 20:54:48 -0400
Received: by vwj40 with SMTP id 40so3458221vwj.33
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2009 17:54:50 -0700 (PDT)
In-Reply-To: <4A4C4F46.2070701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 1, 2009 at 11:10 PM, Eric Dumazet<eric.dumazet@gmail.com> w=
rote:
> Tantilov, Emil S a =C3=A9crit :
>> I see the following trace during netperf stress mixed UDP/TCP IPv4/6=
 traffic. This is on recent pulls from net-2.6 and net-next.
>>
>> [45197.989163] ------------[ cut here ]------------
>> [45197.994309] WARNING: at include/net/sock.h:417 udp_lib_unhash+0x8=
1/0xab()
>> [45197.994311] Hardware name: X7DA8
>> [45197.994314] Modules linked in: e1000 [last unloaded: e1000]
>> [45197.994326] Pid: 7110, comm: netserver Tainted: G =C2=A0 =C2=A0 =C2=
=A0 =C2=A0W =C2=A02.6.31-rc1-net-next-e1000-06250902 #8
>> [45197.994331] Call Trace:
>> [45197.994336] =C2=A0[<ffffffff8135e0dc>] ? udp_lib_unhash+0x81/0xab
>> [45197.994344] =C2=A0[<ffffffff8103cac9>] warn_slowpath_common+0x77/=
0x8f
>> [45197.994349] =C2=A0[<ffffffff8103caf0>] warn_slowpath_null+0xf/0x1=
1
>> [45197.994352] =C2=A0[<ffffffff8135e0dc>] udp_lib_unhash+0x81/0xab
>> [45197.994357] =C2=A0[<ffffffff81301acb>] sk_common_release+0x2f/0xb=
4
>> [45197.994364] =C2=A0[<ffffffff813a0256>] udp_lib_close+0x9/0xb
>> [45197.994369] =C2=A0[<ffffffff81364259>] inet_release+0x58/0x5f
>> [45197.994374] =C2=A0[<ffffffff8138c8bd>] inet6_release+0x30/0x35
>> [45197.994383] =C2=A0[<ffffffff812ff273>] sock_release+0x1a/0x6c
>> [45197.994386] =C2=A0[<ffffffff812ff763>] sock_close+0x22/0x26
>> [45197.994392] =C2=A0[<ffffffff810c69a0>] __fput+0xf0/0x18c
>> [45197.994395] =C2=A0[<ffffffff810c6d00>] fput+0x15/0x19
>> [45197.994399] =C2=A0[<ffffffff810c3c3e>] filp_close+0x5c/0x67
>> [45197.994404] =C2=A0[<ffffffff810c3cc4>] sys_close+0x7b/0xb6
>> [45197.994412] =C2=A0[<ffffffff8100baeb>] system_call_fastpath+0x16/=
0x1b
>> [45197.994418] ---[ end trace 5acab6fc0afdaaa3 ]---
>>
>> Emil--
>
> Thanks for this report Emil.
>
> I could not find a recent change in this area in last kernels.
> If struct sk is hashed (sk_hashed() true), then sk_refcnt was increme=
nted
> in sk_nulls_add_node_rcu(), thus its value should be >=3D 2.
>
> Maybe we have a missing memory barrier somewhere or a list corruption=
=2E
>
> 1) Could you try CONFIG_DEBUG_LIST=3Dy ?
I am running a test with this option now. Sorry for the delayed
response, I was out last week.

> 2) Could you give model of cpu, since it reminds me the ongoing discu=
ssion raised by Jiri Olsa.

processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 23
model name	: Intel(R) Xeon(R) CPU           E5450  @ 3.00GHz
stepping	: 6
cpu MHz		: 2999.790
cache size	: 6144 KB
physical id	: 0
siblings	: 4
core id		: 0
cpu cores	: 4
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx
lm constant_tsc arch_perfmon pebs bts rep_good pni dtes64 monitor
ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow
vnmi flexpriority
bogomips	: 5999.58
clflush size	: 64

2 quad core Xeons, I only included the output from the first to reduce =
clutter.

> CPU1 does an atomic_inc(&sk->sk_refcnt) =C2=A0: refcnt changes from 1=
 to 2
> then CPU2 does an atomic_read(&sk->sk_refcnt) and reads 1 instead of =
2
>
> David, maybe this test is not safe and if we really want to do a chec=
k
> we need to use a stronger atomic function.
>
> If you can reproduce this problem easily could you try following patc=
h ?

It varies from few minutes to hours, but it does reproduce
consistently in my tests so far. I will try your patch once I manage
to get a trace with CONFIG_DEBUG_LIST

Thanks,
Emil
