From: Taylor Lewick <taylor.lewick@gmail.com>
Subject: Re: Increased Latencies when upgrading kernel version
Date: Thu, 1 Apr 2010 20:53:52 -0500
Message-ID: <r2pd585dc4f1004011853q405eaadcq14b50a9e7a4dcf21@mail.gmail.com>
References: <o2vd585dc4f1004011212s65cc2beewed2f19321210a249@mail.gmail.com>
	 <1270156741.2192.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1270156741.2192.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Okay.  I will get this info out to the list Monday.  Briefly, I'm
using identical hardware (server), identical NICs, same drivers,
connected to same switch, and using udpping, hackbench, and an
internall written app to test latency.  Without exception the
evolution has looked like the following.

2.6.16.60 latencies for system and network are fast.  Meaning
hackbench and udpping win, and win by quite a bit.

2.6.27.19 was awful.  2.6.32.1 and 2.6.331. were better for networking
(with some tweaks, i.e. disable netfilter, etc), and I was able to get
networking latencies to within 1-3 microseconds of 2.6.16.60
latencies, but the hackbench results are still pretty bad.

Again, I'll post numbers and more detailed hardware info on Monday
when I'm back at office...

On Thu, Apr 1, 2010 at 4:19 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le jeudi 01 avril 2010 =E0 14:12 -0500, Taylor Lewick a =E9crit :
>> For some time now we've been running an older kernel, 2.6.16.60. =A0=
When
>> we tried to upgrade, first going to 2.6.27.19 and then to 2.6.32.1 a=
nd
>> 2.6.33.1 we noticed that latencies increased. =A0At first we noticed=
 it
>> by doing network tests via udpping, netperf, etc. =A0We made some
>> tweaks, and were able to get network latency to within 1 to 2
>> microseconds of where we were previously on 2.6.16.60. =A0Then we di=
d
>> some more testing, and noticed that system latency also seems higher=
=2E
>>
>> We've done our tests on identical hardware servers, same NICs,
>> connected through same network gear. =A0Basically, we've tried to ke=
ep
>> everything identical except the kernel versions, and we are unable t=
o
>> achieve the same performance for system latency on the newer kernels=
,
>> despite adjusting various kernel settings and recompiling.
>>
>> The latency differences are about 15 microseconds per transaction.
>>
>> At this point, I don't know what else to try. =A0I haven't played ar=
ound
>> with the /proc/sys/kernel/sched_* paramaters under the newer kernels
>> yet. =A0Have tried changing pre-emption modes with little effect, in
>> fact, voluntary preemption seems to be peforming the best for us.
>>
>> At this time the realtime patch isn't really an option for us to
>> consider, at least not yet.
>>
>> Any suggestions? =A0Is this a known issue when upgrading to more rec=
ent
>> kernel versions?
>>
>
> Hi Taylor
>
> Well, this is bit difficult to generically answer to your generic
> question. 15 us more latency per transaction seems pretty bad.
>
> Some inputs would be nice, describing your workload and
> software/hardware architecture.
>
> lspci
> cat /proc/cpuinfo
> cat /proc/interrupts
> dmesg
> ethtool -S eth0
> ethtool -c eth0
>
>
>
>
