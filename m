From: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Tue, 27 Jul 2004 03:16:50 +0300 (EEST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0407270304570.11416-100000@silmu.st.jyu.fi>
References: <16645.34772.760879.146784@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	H?ctor Mart?n <hector@marcansoft.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
	<netdev@oss.sgi.com>, <brad@brad-x.com>, <shemminger@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266193AbUG0ART@vger.kernel.org>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16645.34772.760879.146784@robur.slu.se>
List-Id: netdev.vger.kernel.org

On Tue, 27 Jul 2004, Robert Olsson wrote:

>>>  In summary: High softirq loads can totally kill userland. The reas=
on is that=20
>>>  do_softirq() is run from many places hard interrupts, local_bh_ena=
ble etc=20
>>>  and bypasses the ksoftirqd protection. It just been discussed at O=
LS with
>>>  Andrea and Dipankar and others. Current RCU suffers from this prob=
lem as well.
>> Ok, this explanation makes sense and my point of view I think this i=
s=20
>> quite critical problem if you can "crash" linux kernel just sending =
enough=20
>> packets to network interface for an example.
>=20
>  Well the packets also has to create hard softirq loads in practice t=
his means route
>  lookup or something else for normal traffic the RX_SOFIRQ is very we=
ll behaved
>  and schedules itself to give other softirq's a chance to run also I'=
ll guess you=20
>  have softirq's not only from the network. If you decrease your load =
a bit you come
>  to more nomal operation?

The system will be more responsive but won't ever come back to normal=20
operation and if I use my computer just for some chatting/writing/brows=
ing=20
the ksoftirqd-problem won't ever happen.=20

It is also very hard to reproduce with only high network load. I ran so=
me=20
test with 100Mbps load (RX and TX both) for 24hours without any problem=
s=20
but soon as I started to compile some stuff or doing something=20
cpu-intensive the system would do crash-boom-bang.

>> I would be more than glad to help you in testing if you want to publ=
ish=20
>> some patches.=20
>  Well maybe we should start to verify that this problem. Alexey did a=
 litte program=20
>  doing gettimeofday to run to see how long user mode could be starved=
=2E Also note we=20
>  add new source of softirq's.=20

=46irst run:

--
timestamp diff =3D 1, maxlat =3D 50963
timestamp diff =3D 0, maxlat =3D 50963
timestamp diff =3D 0, maxlat =3D 50963
timestamp diff =3D 1, maxlat =3D 50963
timestamp diff =3D 0, maxlat =3D 50963
timestamp diff =3D 0, maxlat =3D 50963
new maxlat =3D 124428
new maxlat =3D 511817
timestamp diff =3D 1, maxlat =3D 511817
new maxlat =3D 749913
new maxlat =3D 775142
**4581159
new maxlat =3D 4581159
**1704065
**1464153
timestamp diff =3D 1, maxlat =3D 4581159
**1448939
**1464013
**1021339
**1568588
**1861657
timestamp diff =3D 0, maxlat =3D 4581159
--

Second run:

--
timestamp diff =3D 0, maxlat =3D 832003
timestamp diff =3D 1, maxlat =3D 832003
timestamp diff =3D 0, maxlat =3D 832003
timestamp diff =3D 0, maxlat =3D 832003
timestamp diff =3D 0, maxlat =3D 832003
timestamp diff =3D 1, maxlat =3D 832003
**1793951
new maxlat =3D 1793951
timestamp diff =3D 0, maxlat =3D 1793951
**2579893
new maxlat =3D 2579893
timestamp diff =3D 0, maxlat =3D 2579893
timestamp diff =3D 0, maxlat =3D 2579893
timestamp diff =3D 0, maxlat =3D 2579893
**1004449
**3199625
new maxlat =3D 3199625
timestamp diff =3D 0, maxlat =3D 3199625
timestamp diff =3D 1, maxlat =3D 3199625
--

When the system has gone to this state you will have to wait quite a lo=
ng=20
time to receive a new line.

--
Pasi Sj=F6holm=20
