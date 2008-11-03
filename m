From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd) [SOLVED]
Date: Mon, 3 Nov 2008 15:03:40 -0200
Message-ID: <490f2ef1.060ec00a.0e03.40d0@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
	<alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
	<Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
	<48e5364d.0603c00a.6e25.fffff993@mx.google.com>
	<Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
	<48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com>
	<alpine.LFD.2.00.0810052008131.3398@apollo>
	<48ed0b51.0913c00a.7715.4aa7@mx.google.com>
	<alpine.LFD.2.00.0810082154420.3237@apollo>
	<48f2c9d7.0603c00a.1df2.ffff9357@mx.google.com>
	<Pine.LNX.4.64.0810131633370.3843@wrl-59.cs.helsinki.fi>
	<48f9251b.1626360a.6574.61ec@mx.google.com>
	<Pine.LNX.4.64.0810210028550.30254@wrl-59.cs.helsinki.fi>
	<48fe8c06.4719360a.3996.04a9@mx.google.com>
	<Pine.LNX.4.64.0810301232360.7072@wrl-59.cs.helsinki.fi>
	<490d4120.0807c00a.32d8.5eaf@mx.google.com>
	<Pine.LNX.4.64.0811031705390.23792@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:20846 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756008AbYKCRDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 12:03:48 -0500
Received: by qw-out-2122.google.com with SMTP id 3so1188109qwe.37
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 09:03:47 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0811031705390.23792@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Nov 2008 17:37:09 +0200 (EET)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Once there's any kind of flow control, anything jamming downstream wi=
ll=20
> eventually make upstream to stall as well (or to appear as not workin=
g=20
> as expected. Sadly, it's exactly opposite from correctness point of v=
iew=20
> as flow control is a feature in TCP, not a bug :-)). Thus I occassion=
ally=20
> run to these tcp with flow control not working reports which turn to =
be=20
> totally unrelated.
>=20
> This still doesn't explain everything though afaik... E.g., why did t=
he=20
> sendto() to SOCK_DGRAM socket hung.

	Well, the fact that the problem happened since 2.6.25 kernel
make me believe that it could exist a possible kernel issue too, but I
think that most part was caused by syslogd.

> And you had the same old syslogd on both hosts?

	Yes. My desktop and server have the same installation.

> In any case the loss of every other character deterministically sound=
s=20
> like a real bug in the syslogd since it doesn't make too much sense t=
o=20
> happen in kernel->syslogd communication (where I'd expect it to not s=
how=20
> up in such consistent pattern but would cause more randomness).

	Yes. With the new compiled syslogd it doesn't happen anymore.
And I don't have stall too.

> It's not clear what caused this to happen _now_, nor the exact mechan=
ism.

	Ok.

> This is more of a philosophical question than something else... it's=20
> always balancing between data loss (=3Dpossibly losing a logline of a=
n=20
> important event) or possibility of a stall. But this shouldn't be a=20
> concern in the case where SOCK_DGRAM was used by the sudo (like in th=
e=20
> strace you sent to sudo people), in general UDP doesn't guarantee=20
> reliability so not delivering wouldn't be a problem but I don't know =
if=20
> PF_FILE domain does something otherwise in there.

	I see.

> Until we know more details than that killing syslogd helped it's hard=
 to=20
> tell what is the actual cause. And I have no clue about semantics of=20
> /dev/log anyway.

	Ok. Anyway, at least the problem was registered and if in the
future we have something related, maybe this can help someone.


--=20
