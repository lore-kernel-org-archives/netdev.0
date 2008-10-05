From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Sun, 5 Oct 2008 14:52:50 -0300
Message-ID: <48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
	<alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
	<48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
	<alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
	<48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
	<alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
	<48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
	<alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
	<Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
	<48e5364d.0603c00a.6e25.fffff993@mx.google.com>
	<Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:33101 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700AbYJERw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 13:52:59 -0400
Received: by qw-out-2122.google.com with SMTP id 3so520065qwe.37
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2008 10:52:57 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 3 Oct 2008 00:19:08 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> On Thu, 2 Oct 2008, D=E2niel Fraga wrote:
>=20
> > On Thu, 2 Oct 2008 23:31:28 +0300 (EEST)
> > "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> >=20
> > > Ah, I was kind of thinking that you were doing something net rela=
ted=20
> > > using some raw socket thing (such as traceroute) when you earlier=
=20
> > > mentioned sudo (iirc, we never really discussed what you usually =
do with=20
> > > it when you see the stall).
> >=20
> > 	I read nntp groups everyday and I use leafnode. The stall on my
> > desktop happens when I run fetchnews (which must be run as user "ne=
ws"
> > so I have to use sudo). Usually the stall on my desktop happens whe=
n
> > I'm using fetchnews or some other command run by sudo.
>=20
> Yes yes, I'd be specificly interested to have some rough idea what th=
at
> "some other command" includes, especially as some seem to be non-net=20
> related since you mentioned e.g., that /dev/log thing?

	Here we go folks, good and bad news:

1) the good news is that the Thomas' patch detected the stall, but...

2)

Oct  5 14:23:03 teleporto vmunix: Tracer stopped
Oct  5 14:23:13 teleporto last message repeated 2 times

	if it had really stopped, the message wouldn't be repeated 2
times.

	and

fraga@teleporto ~$ cat /debug/tracing/tracing_enabled=20
1

	In other words, the tracing wasn't really stopped.

	So I couldn't get what Thomas want. Should I activated the
initial auto-checking of ftrace to see if it's really working? Very
strange the fact it wasn't stopped.

	***

	I was waiting for 2 days to a stall and I managed to get the
stall by using "sudo" multiple times. It seems that sudo really makes
this bug hit.
=09
	And now? Should we revise Thomas patch? Maybe a bug in ftrace
code that prevents it from being stopped? It seems that:

ftrace_enabled =3D 0;

	isn't really stopping the tracing.

	Thank you.

--=20
