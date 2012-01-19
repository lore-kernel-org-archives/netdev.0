From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Interpreting perf stat on netperf and netserver
Date: Thu, 19 Jan 2012 09:29:04 +0100
Message-ID: <CAL8zT=jP4Bm=WM0=OLcRgeetzXb0f_ZL0TiDvPAhkbA9UuxpBA@mail.gmail.com>
References: <CAL8zT=gNwDDXcbH+hoZApc63ArW2quzHJ1gRrPSxKP7jE04KLw@mail.gmail.com>
 <4F170629.8090307@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:56142 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611Ab2ASI30 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 03:29:26 -0500
Received: by wgbgn7 with SMTP id gn7so4470079wgb.1
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 00:29:25 -0800 (PST)
In-Reply-To: <4F170629.8090307@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/18 Rick Jones <rick.jones2@hp.com>:
> On 01/18/2012 03:33 AM, Jean-Michel Hautbois wrote:
>>
>> Hi all,
>>
>> I am currently using netperf/netserver in order to characterize a
>> benet emulex network device on a machine with 2 Xeon5670.
>> I am using the latest linux kernel from git (3.2.0+).
>> I am facing several issues, and I am trying to understand the
>> following perf stat launched on netserver :
>>
>> =C2=A0Performance counter stats for process id '5043':
>
>
> If you aren't already you may want to gather system-wide data as well=
 - not
> everything networking is guaranteed to run in the netserver's (or net=
perf's)
> context.
>
> Might also be good to include the netperf command line driving that
> netserver. =C2=A0That will help folks know if the netserver is receiv=
ing data
> (_STREAM), sending data (_MAERTS) or both (_RR) (though perhaps that =
can be
> gleaned from the routine names in the profile.

Well, I am only launching netserver without any parameter.

>
>>
>> =C2=A0 =C2=A0 =C2=A0 15452.992135 task-clock =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0# =C2=A0 =C2=A00.450 CPUs utilized
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 189678 context-switches =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0# =C2=A0 =C2=A00.012 M/sec
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A05 CPU-=
migrations =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0# =C2=A0 =C2=A00.00=
0 M/sec
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0275 page-faul=
ts =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 # =C2=A0 =C2=A00.00=
0 M/sec
>> =C2=A0 =C2=A0 =C2=A0 =C2=A048490467936 cycles =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0# =C2=A0 =C2=A03.138 GHz
>> =C2=A0 =C2=A0 =C2=A0 =C2=A033005879963 stalled-cycles-frontend =C2=A0=
 # =C2=A0 68.07% frontend cycles
>> idle
>> =C2=A0 =C2=A0 =C2=A0 =C2=A016325855769 stalled-cycles-backend =C2=A0=
 =C2=A0# =C2=A0 33.67% backend =C2=A0cycles
>> idle
>> =C2=A0 =C2=A0 =C2=A0 =C2=A027340520316 instructions =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0# =C2=A0 =C2=A00.56 =C2=A0insns per cycl=
e
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0# =C2=A0 =C2=A01.21 =C2=A0stalled cycles per
>> insn
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 4745604818 branches =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0# =C2=A0307.099 M/sec
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 67513124 branch-misses =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 # =C2=A0 =C2=A01.42% of all branches
>>
>> =C2=A0 =C2=A0 =C2=A0 34.303567279 seconds time elapsed
>>
>> I am trying to understand the "stalled-cycles-frontend" and
>> "stalled-cycles-backend" lines.
>> It seems that frontend is high, and in red :) but I can't say why...
>
>
> Perhaps the stalls are for cache misses - at least cache misses are a=
 common
> reason for stalls. =C2=A0I believe that perf has a way to be more spe=
cific about
> the PMU events of interest.

Yes, there is some events for that :). But I didn't know if stall was
cache misses related or not :).

JM
