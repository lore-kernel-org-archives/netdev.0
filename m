From: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Subject: Re: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Thu, 6 Oct 2016 07:01:36 +0000
Message-ID: <13c3cd3ffee4490fb22b8de383e51361@FE-MBX1012.de.bosch.com>
References: <c91ce66d47ff470a94e10e2347eafe4a@FE-MBX1012.de.bosch.com>
 <ac1207c12ad34059956c2729ccf31e97@FE-MBX1012.de.bosch.com>
 <20160923123224.odybv2uos6tot6it@linutronix.de>
 <ae35c863cdf246ac8da94277418921ef@FE-MBX1012.de.bosch.com>
 <20160923144140.5tkzeymamrb5qnsv@linutronix.de>
 <a5ea146cf078457ab001131ca0886b0b@FE-MBX1012.de.bosch.com>
 <20160928194519.GA32423@jcartwri.amer.corp.natinst.com>
 <487032ca81f84e70bdacc39a024eff5e@FE-MBX1012.de.bosch.com>
 <20161004193445.GF10625@jcartwri.amer.corp.natinst.com>
 <584755c2766e4b94a604ece16760fe14@FE-MBX1012.de.bosch.com>
 <20161005155959.GH10625@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="_002_13c3cd3ffee4490fb22b8de383e51361FEMBX1012deboschcom_"
Cc: Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Julia Cartwright <julia@ni.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Greg <gvrose8192@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-v.fe.bosch.de ([139.15.237.11]:35843 "EHLO
        smtp6-v.fe.bosch.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752214AbcJFHBk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 03:01:40 -0400
In-Reply-To: <20161005155959.GH10625@jcartwri.amer.corp.natinst.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_13c3cd3ffee4490fb22b8de383e51361FEMBX1012deboschcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi all,
>=20
> Although, to be clear, it isn't the fact that there exists 8 threads, it'=
s that the device is
> firing all 8 interrupts at the same time.  The time spent in hardirq cont=
ext just waking
> up all 8 of those threads (and the cyclictest wakeup) is enough to cause =
your
> regression.
>=20
> netdev/igb folks-
>=20
> Under what conditions should it be expected that the i350 trigger all of =
the TxRx
> interrupts simultaneously?  Any ideas here?
>=20
> See the start of this thread here:
>=20
>   http://lkml.kernel.org/r/d648628329bc446fa63b5e19d4d3fb56@FE-
> MBX1012.de.bosch.com
>=20
Greg recommended to use "ethtool -L eth2 combined 1" to reduce the number o=
f queues.
I tried that. Now, I have actually only three irqs (eth2, eth2-rx-0, eth2-t=
x-0).
However the issue remains the same.

I ran the cyclictest again:
# cyclictest -a -i 105 -m -n -p 80 -t 1  -b 23 -C
(Note: When using 105us instead of 100us the long latencies seem to occur m=
ore often).

Here are the final lines of the kernel trace output:
  <idle>-0       4d...2.. 1344661649us : sched_switch: prev_comm=3Dswapper/=
4 prev_pid=3D0 prev_prio=3D120 prev_state=3DR =3D=3D> next_comm=3Drcuc/4 ne=
xt_pid=3D56 next_prio=3D98
ktimerso-46      3d...2.. 1344661650us : sched_switch: prev_comm=3Dktimerso=
ftd/3 prev_pid=3D46 prev_prio=3D98 prev_state=3DS =3D=3D> next_comm=3Dswapp=
er/3 next_pid=3D0 next_prio=3D120
ktimerso-24      1d...2.. 1344661650us : sched_switch: prev_comm=3Dktimerso=
ftd/1 prev_pid=3D24 prev_prio=3D98 prev_state=3DS =3D=3D> next_comm=3Dswapp=
er/1 next_pid=3D0 next_prio=3D120
ktimerso-79      6d...2.. 1344661650us : sched_switch: prev_comm=3Dktimerso=
ftd/6 prev_pid=3D79 prev_prio=3D98 prev_state=3DS =3D=3D> next_comm=3Dswapp=
er/6 next_pid=3D0 next_prio=3D120
ktimerso-35      2d...2.. 1344661650us : sched_switch: prev_comm=3Dktimerso=
ftd/2 prev_pid=3D35 prev_prio=3D98 prev_state=3DS =3D=3D> next_comm=3Dswapp=
er/2 next_pid=3D0 next_prio=3D120
  rcuc/5-67      5d...2.. 1344661650us : sched_switch: prev_comm=3Drcuc/5 p=
rev_pid=3D67 prev_prio=3D98 prev_state=3DS =3D=3D> next_comm=3Dktimersoftd/=
5 next_pid=3D68 next_prio=3D98
  rcuc/7-89      7d...2.. 1344661650us : sched_switch: prev_comm=3Drcuc/7 p=
rev_pid=3D89 prev_prio=3D98 prev_state=3DS =3D=3D> next_comm=3Dktimersoftd/=
7 next_pid=3D90 next_prio=3D98
ktimerso-4       0d...211 1344661650us : sched_wakeup: comm=3Drcu_preempt p=
id=3D8 prio=3D98 target_cpu=3D000
  rcuc/4-56      4d...2.. 1344661651us : sched_switch: prev_comm=3Drcuc/4 p=
rev_pid=3D56 prev_prio=3D98 prev_state=3DS =3D=3D> next_comm=3Dktimersoftd/=
4 next_pid=3D57 next_prio=3D98
ktimerso-4       0d...2.. 1344661651us : sched_switch: prev_comm=3Dktimerso=
ftd/0 prev_pid=3D4 prev_prio=3D98 prev_state=3DS =3D=3D> next_comm=3Drcu_pr=
eempt next_pid=3D8 next_prio=3D98
ktimerso-90      7d...2.. 1344661651us : sched_switch: prev_comm=3Dktimerso=
ftd/7 prev_pid=3D90 prev_prio=3D98 prev_state=3DS =3D=3D> next_comm=3Dswapp=
er/7 next_pid=3D0 next_prio=3D120
ktimerso-68      5d...2.. 1344661651us : sched_switch: prev_comm=3Dktimerso=
ftd/5 prev_pid=3D68 prev_prio=3D98 prev_state=3DS =3D=3D> next_comm=3Dswapp=
er/5 next_pid=3D0 next_prio=3D120
rcu_pree-8       0d...3.. 1344661652us : sched_wakeup: comm=3Drcuop/0 pid=
=3D10 prio=3D120 target_cpu=3D000
ktimerso-57      4d...2.. 1344661652us : sched_switch: prev_comm=3Dktimerso=
ftd/4 prev_pid=3D57 prev_prio=3D98 prev_state=3DS =3D=3D> next_comm=3Dswapp=
er/4 next_pid=3D0 next_prio=3D120
rcu_pree-8       0d...2.. 1344661653us+: sched_switch: prev_comm=3Drcu_pree=
mpt prev_pid=3D8 prev_prio=3D98 prev_state=3DS =3D=3D> next_comm=3Dkworker/=
0:0 next_pid=3D5 next_prio=3D120
kworker/-5       0dN.h2.. 1344661741us : sched_wakeup: comm=3Dcyclictest pi=
d=3D6314 prio=3D19 target_cpu=3D000
kworker/-5       0d...2.. 1344661742us : sched_switch: prev_comm=3Dkworker/=
0:0 prev_pid=3D5 prev_prio=3D120 prev_state=3DR+ =3D=3D> next_comm=3Dcyclic=
test next_pid=3D6314 next_prio=3D19
cyclicte-6314    0d...2.. 1344661743us : sched_switch: prev_comm=3Dcyclicte=
st prev_pid=3D6314 prev_prio=3D19 prev_state=3DS =3D=3D> next_comm=3Drcuop/=
0 next_pid=3D10 next_prio=3D120
 rcuop/0-10      0d...2.. 1344661744us!: sched_switch: prev_comm=3Drcuop/0 =
prev_pid=3D10 prev_prio=3D120 prev_state=3DS =3D=3D> next_comm=3Dkworker/0:=
0 next_pid=3D5 next_prio=3D120
kworker/-5       0dN.h2.. 1344661858us : sched_wakeup: comm=3Dcyclictest pi=
d=3D6314 prio=3D19 target_cpu=3D000
kworker/-5       0d...2.. 1344661859us : sched_switch: prev_comm=3Dkworker/=
0:0 prev_pid=3D5 prev_prio=3D120 prev_state=3DR+ =3D=3D> next_comm=3Dcyclic=
test next_pid=3D6314 next_prio=3D19
cyclicte-6314    0d...2.. 1344661860us!: sched_switch: prev_comm=3Dcyclicte=
st prev_pid=3D6314 prev_prio=3D19 prev_state=3DS =3D=3D> next_comm=3Dkworke=
r/0:0 next_pid=3D5 next_prio=3D120
kworker/-5       0dN.h2.. 1344661966us : sched_wakeup: comm=3Dcyclictest pi=
d=3D6314 prio=3D19 target_cpu=3D000
kworker/-5       0d...2.. 1344661966us : sched_switch: prev_comm=3Dkworker/=
0:0 prev_pid=3D5 prev_prio=3D120 prev_state=3DR+ =3D=3D> next_comm=3Dcyclic=
test next_pid=3D6314 next_prio=3D19
cyclicte-6314    0d...2.. 1344661967us+: sched_switch: prev_comm=3Dcyclicte=
st prev_pid=3D6314 prev_prio=3D19 prev_state=3DS =3D=3D> next_comm=3Dkworke=
r/0:0 next_pid=3D5 next_prio=3D120
kworker/-5       0dN.h2.. 1344662052us : sched_wakeup: comm=3Dcyclictest pi=
d=3D6314 prio=3D19 target_cpu=3D000
kworker/-5       0d...2.. 1344662053us : sched_switch: prev_comm=3Dkworker/=
0:0 prev_pid=3D5 prev_prio=3D120 prev_state=3DR+ =3D=3D> next_comm=3Dcyclic=
test next_pid=3D6314 next_prio=3D19
cyclicte-6314    0d...2.. 1344662054us!: sched_switch: prev_comm=3Dcyclicte=
st prev_pid=3D6314 prev_prio=3D19 prev_state=3DS =3D=3D> next_comm=3Dkworke=
r/0:0 next_pid=3D5 next_prio=3D120
kworker/-5       0dN.h2.. 1344662168us : sched_wakeup: comm=3Dcyclictest pi=
d=3D6314 prio=3D19 target_cpu=3D000
kworker/-5       0d...2.. 1344662168us : sched_switch: prev_comm=3Dkworker/=
0:0 prev_pid=3D5 prev_prio=3D120 prev_state=3DR+ =3D=3D> next_comm=3Dcyclic=
test next_pid=3D6314 next_prio=3D19
cyclicte-6314    0d...2.. 1344662169us+: sched_switch: prev_comm=3Dcyclicte=
st prev_pid=3D6314 prev_prio=3D19 prev_state=3DS =3D=3D> next_comm=3Dkworke=
r/0:0 next_pid=3D5 next_prio=3D120
kworker/-5       0dN.h2.. 1344662255us : sched_wakeup: comm=3Dirq/48-eth2-t=
x- pid=3D6310 prio=3D49 target_cpu=3D000
kworker/-5       0dN.h3.. 1344662256us : sched_wakeup: comm=3Dirq/47-eth2-r=
x- pid=3D6309 prio=3D49 target_cpu=3D000
kworker/-5       0d...2.. 1344662256us : sched_switch: prev_comm=3Dkworker/=
0:0 prev_pid=3D5 prev_prio=3D120 prev_state=3DR+ =3D=3D> next_comm=3Dirq/48=
-eth2-tx- next_pid=3D6310 next_prio=3D49
irq/48-e-6310    0d...2.. 1344662259us : sched_switch: prev_comm=3Dirq/48-e=
th2-tx- prev_pid=3D6310 prev_prio=3D49 prev_state=3DS =3D=3D> next_comm=3Di=
rq/47-eth2-rx- next_pid=3D6309 next_prio=3D49
irq/47-e-6309    0d...2.. 1344662260us+: sched_switch: prev_comm=3Dirq/47-e=
th2-rx- prev_pid=3D6309 prev_prio=3D49 prev_state=3DS =3D=3D> next_comm=3Dk=
worker/0:0 next_pid=3D5 next_prio=3D120
kworker/-5       0dN.h2.. 1344662300us : sched_wakeup: comm=3Dcyclictest pi=
d=3D6314 prio=3D19 target_cpu=3D000
kworker/-5       0d...2.. 1344662300us : sched_switch: prev_comm=3Dkworker/=
0:0 prev_pid=3D5 prev_prio=3D120 prev_state=3DR+ =3D=3D> next_comm=3Dcyclic=
test next_pid=3D6314 next_prio=3D19
cyclicte-6314    0.....11 1344662306us : tracing_mark_write: hit latency th=
reshold (39 > 23)

Just before the long latency,  the irqs "48-eth2-tx" and "48-eth2-rx" are a=
ctive.
When looking at the 4th line from the bottom, the time for irq/47 is 134466=
2260us, for the next line (kworker) it is 1344662300us.
Does this mean that the irq/47 took 40us for irq processing? Or is this a m=
isinterpretation?

For more lines of the trace please see the attached trace-extract.gz.

Thanks for any feedback.

Regard

Mahias







--_002_13c3cd3ffee4490fb22b8de383e51361FEMBX1012deboschcom_
Content-Type: application/x-gzip; name="trace-extract.gz"
Content-Description: trace-extract.gz
Content-Disposition: attachment; filename="trace-extract.gz"; size=1118;
	creation-date="Thu, 06 Oct 2016 07:00:06 GMT";
	modification-date="Thu, 06 Oct 2016 06:43:51 GMT"
Content-Transfer-Encoding: base64

H4sICKfy9VcAA3RyYWNlLWV4dHJhY3QA1ZnZctowFIbv8xTqXTsdO9oXpuQRctE+QIYxbvAkBGqb
krx9jRdZXmTLBjKUq0CM/4+z/DqSg4/gNQrS0OMEUZC94Nr3fez7ABFKOUcMy0PyZQGSYBOun5Jj
lAabBdjH4d+nYLfdLoPyBklafLiP1sv8XsW7ONotkSreJOkqDZe/wHL5AN7C97S4QXJc7fdhfA+L
z07fr/7Mv4zhHQA/ovVr+OBBULzg+tHfkBoyEzwkoII8rl7Cw34BOnw1WkGVruLnMMPYH5YQ9so0
Y8EJNmS6sah/ig4FNOOAoRmIn61AGKQ6EjmuEQx1F4wljBNySL7fYMJ8M2FU2BL2kkbbME52v9P1
KZDZ3cuEKTmaMNquC7tMHByCe5rfn/F+AdoVEBMFRC4gVb+A6AqwiQKsqGrRL8AcaprKK9Z0M5m6
XsyaVrILSTrlIl3KhRTlYkkn6eqgeToo18GWukRdHT5Ph+c6wlI9vKuD5+ngXIewfh3c3wYzdIpu
UHBSN8zQKZtCOjcFnadT2oel+Xrsg8xsPnJ28xGj+Xiz+6rLPGpaBEG4plTWaBx38cvJHRaFVZcl
dAIb82reiYVyigU/Oxa8jkXWW8NOhGZSorMpUU2Jx/wSz6TEZ1PimjLzj2FKNpOSzaIsl8d6lBIj
eGImnpiPJ2o8OVaJdCYenY9HazxmNQ1usTYGB/Fa63aFSLnBqKTLHErsc6imxNTSzhMojZbGdDIl
cqDM3KjfGidQGvYo1GRK7kCZ9Xm/6UygNIyHsMmU2E4JQNH3Xtbu/aYzQllN1XprJJzxmiNIbTyy
3dlF73tSWYzHBdFwHeme5+Y0phEVtHV3Y9eAUD9ie1uS3ScMt/tix22ZwnSqqMe4xeEYGo+DYW/M
3TuaU1ztcsIpDu6Irc2sdjlnUDOa9VphoVTQVlDulEZdKTi5M4WDf2T9YOlMd0qzQeVkSmanrOLt
ycYwbFLigcrf7cszCwStk7AOBBO2uh8+ZmptQXT5uztVPRtMDESDcvicqeED2qrcO9TYWdT92a6p
8iKPachHf2NACnqJg8EemWYsBB3JmLlN0vkamMa+X+dsUFAyyHn22WDVAhoSdRbo8hIPQVss6eCB
s+6yChANjLXXqSrJrMcDl6wqyYYn/FupKsnhdR8RXCZrivPPyFpT5nazpri47nOCi2QNQ/t6e8Gs
ZTLDzngjWcs4h93xRrKG+Gc4ZEvmdrOGuPofeg0zZstaFP+5p9IL0w320nevSl055VKX1DUebGVa
VjfOtUShFWstqCZoNcPf1LpCmbSjY9aKOQBRdVdd6uX/6oUdXvU7mTAKxpyE6GDBtGNsEEPVQyxy
Yqh6iU/r/0B1d/JZE0PlTHyZEifQenBxSWNqytyQMfmnlz7HyTiLzkjjVRC9PT9tV/HL0zGO0nAB
NlEKXjPxt+ADpJs4TDa71zX4ShR4AJh8u/sHF2j55TsiAAA=

--_002_13c3cd3ffee4490fb22b8de383e51361FEMBX1012deboschcom_--
