From: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Tue, 3 Aug 2004 23:19:33 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408032256110.2281-100000@silmu.st.jyu.fi>
References: <20040803185026.A10580@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        H?ctor Mart?n <hector@marcansoft.com>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
        <netdev@oss.sgi.com>, <brad@brad-x.com>, <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040803185026.A10580@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Aug 2004, Francois Romieu wrote:

> > The first log file is with both patchs applied and the second one wit=
h one=20
> > little change to rx8139_rx() to show if it even goes to through=20
> >=20
> > "        while (netif_running(dev) && received < budget
> >                && (RTL_R8 (ChipCmd) & RxBufEmpty) =3D=3D 0) {"-sectio=
n.
> >=20
> > This was the change which I made.. so you can see in the second log f=
ile=20
> > that there won't be any of these messages after the driver has crashe=
d.=20
> If you remove the "if (received > 0) {" test in r8139-10.patch and keep
> both patches applied, I assume you are back to a crash within 15min (in=
stead
> of within 2min as suggested by the log), right ?

Hmm,

I removed "if (received > 0) {" and tested it something like 3 hours and=20
wasn't able to crash the driver. I will test it for couple more hours=20
tomorrow and if I'm not still able the crash it, we may have find some=20
sort of a solution.

I'm not sure yet if it's a good one because of that earlier crash I had.
I guess I will also test if

- read the interruption status word that the driver will ack before the
  actual processing is done;

has something to do it.

We'll see.. I'll get back to you tomorrow with more information.

--
Pasi Sj=F6holm
