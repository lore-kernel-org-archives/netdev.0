From: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Fri, 30 Jul 2004 15:56:10 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407301530130.23039-100000@silmu.st.jyu.fi>
References: <16650.4736.456106.603065@robur.slu.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        H?ctor Mart?n <hector@marcansoft.com>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
        <netdev@oss.sgi.com>, <brad@brad-x.com>, <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16650.4736.456106.603065@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 30 Jul 2004, Robert Olsson wrote:

> You should monitor the the user app (gettimeofday()monitoring for starv=
ation
> this is the most important measure and what we are trying to improve.

I can do that after couple of days.. I have to get married tomorrow and=20
spend some time with my wife. =3D)
=20
> We can hardly expect softirq's alone to give us the balance of load we =
wish.=20
> At overload something has to get less resources. Even we defer all soft=
irq's=20
> to scheduler context there is no way making any distinguish between the=
m=20
> unless we run them in separate processes i.e one RX_SOFIRQ, TX_SOFIRQ e=
tc.=20
> This could solve some problem I just discussed with Jamal where the RX=20
> softirq overruns the TX softirq and causes drop at egress (qdisc) when =
bus=20
> BW is saturated. Running softirq's under schedules context's can cause =
other=20
> delays and other problems.

Ok, I understand that you can't do 110% if you have only 100% so someone=20
has to wait. It would not matter if networks speed would slow down to=20
1/100 from the maximum speed if it would still somehow work and not=20
crashing the whole userspace.

I don't remember if I have said this but when the ksoftirqd has started t=
o=20
take all the cpu-time there is no way to stop it excluding booting=20
computer. You can kill or stop all the processes which are taking your=20
cpu-time (ie. source compiling) but network wont start to work or neither=
=20
there is no free cpu-time for use because ksoftirqd won't stop eating it.

Actually, for now I would not care how much the kernel would slow down bu=
t=20
we have to get some stability. Restarting your computer everytime this=20
happens is not a solution.

> So most ksoftirq's runs most softirq's which is good. Without this you =
would=20
> not be able to type any commands at all. Also we see some effects from =
the=20
> path. Can you monitor userland starvation here too?

Sure..=20

> > - When the ksoftirqd starts to eat cpu-time time_squeeze-value (3rd=20
> > column) starts growing (in both cases it's same thing).=20
> This OK as we have to throttle.

Sure, but we should not crash the whole userspace. Why does kernel=20
suddenly think that it won't give any time for softirq's. Or it=20
does because I can write commands and etc. but the network won't work at =
all.
=20
> > - Total-column's value stops growing although network file transfers=20
> > are still on. (1st column)
> Well ksoftirqd now runs RX softirq and competes heavily with other proc=
esses=20
> for your CPU you may have to adjust priorities to get your desired bala=
nce.
> Can you experiment a bit?

There is nothing to priorise after I have killed/quitted the jobs which w=
e=20
taking all the cpu-time. Nothing more left than ksoftirqd and it will eat=
=20
all the cpu-time.

Of course I could try something like "nice make -j3" and see if it will=20
still do the same shit.
 =20
--
Pasi Sj=F6holm
