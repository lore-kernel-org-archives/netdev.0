From: Alexey Osipov <simba@lerlan.ru>
Subject: Re: Single core gets pegged on multi-core PPTP server
Date: Fri, 20 Jan 2012 06:28:16 +0700
Message-ID: <1327015696.4513.6.camel@dahari>
References: <CAJuWrdtDgeCOSEvD-ytfwGj4UQeOtjeqUZd3Y1SLpbbsSvrycg@mail.gmail.com>
	 <CAFnNQmy8yDVuAToaxfi4BA3wSU4mvhJ22O3KdBjn=vtSL-zvLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulus@samba.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Bradley Peterson <despite@gmail.com>
To: Emanuil Hristov <int986@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <CAFnNQmy8yDVuAToaxfi4BA3wSU4mvhJ22O3KdBjn=vtSL-zvLg@mail.gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

AFAIK, accel-ppp !=3D accel-pptp.

accel-pptp - kernel module for speed-up pptp processing done by pppd.

accel-ppp - entirely new implementation of ppp written from scratch. No
pppd is used in this case.

So, if in your configuration, you need to use some other plugins for
pppd, you can't just switch from accel-pptp to accel-ppp, because
accel-ppp have it's own plugin API.

Regards,
Alexey.

=D0=92 =D0=9F=D1=82=D0=BD, 20/01/2012 =D0=B2 00:55 +0200, Emanuil Hrist=
ov =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Hi,
> try with more recent version of accel-ppp (1.5 is lastest) and newer
> kernel - there
> are several critical bugs in older kernels
>=20
>=20
> P.S the project accel-pptp has changed its name to accel-ppp
>=20
> cheers
>=20
> On Fri, Jan 20, 2012 at 12:35 AM, Bradley Peterson <despite@gmail.com=
> wrote:
> > Hello,
> >
> > I am trying to test the capacity of a linux PPTP server, both in
> > number of connections, and in packets per second.  I am using kerne=
l
> > 2.6.38.8, with the ppp, pptp, and gre modules, and accel-pptp 0.8.3=
=2E
> > I have RPS, RFS, and XPS enabled on the network devices for SMP
> > support.
> >
> > But I'm seeing one CPU get pegged out with soft interrupt, while th=
e
> > others are almost completely idle.
> >
> > In my current test, I'm starting 250 pptp connections from another
> > server, then running iperf across each connection.  The client mach=
ine
> > pegs out, sure, but I'm surprised the server pegs out a single CPU.
> > With RPS, I would expect softirq's to be more balanced.
> >
> > Where could the bottleneck be?  Do all ppp packets need to be
> > processed serially?
> >
> > Brad
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ppp" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


