From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Thu, 30 Oct 2008 16:16:04 -0200
Message-ID: <4909f9e9.0b87460a.0354.ffff97d8@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
	<alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.240]:57245 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758522AbYJ3SQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 14:16:13 -0400
Received: by hs-out-0708.google.com with SMTP id 4so361884hsl.5
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 11:16:11 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810301232360.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Oct 2008 12:43:05 +0200 (EET)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Nothing particularly interesting in it (sorry for the delay, there we=
re=20
> some other bugs in the meantime to fix and partially because I was ou=
t=20
> of ideas). Minor increase in cpu/wa after nmap, before that it was 0-=
2,=20
> mostly zero.

	Hi Ilpo. No problem, it's better late than never ;)

> Another thing that occurred to me today is that all these events I kn=
ow of=20
> are related to syslog/klogd (I don't know too well how they relate to=
 each=20
> other and what functionality is provided by each, thus I refer them h=
ere=20
> as one :-)).
>=20
> - sudo sendmsg'ed to /dev/log and stalled
> - every-2nd-char missing in printk relates to it
> - usb does cause printks
> - server processes likely do some logging (and can then hang on waiti=
ng
>   until that finishes and therefore eventually no worker is available=
 to=20
>   process requests)
>=20
> ...Some other type of case I'm missing here?

	Yes, it is that. Anyway I'm talking directly to netfilter
people and they suggested that I use ulogd to capture the exact packet
when the stall happens using pcap. I'll try that. If they can figure it
out what happens to make the log prints every other char, maybe we have
a hint.

> Perhaps we could try to solve it though stracing syslogd...

	Yes I can trace it.

> Did you ever actually try btw with something else than NO_TICK, we=20
> discussed it at some point of time but I'm not sure what was the end=20
> result of what got tested and what not?

	I tried with many options, with TICK enabled and disabled, high
res timer enabled and disabled and other options in the kernel, but it
didn't make any difference.

	I'll try with netfilter people and if i get something, I
will reply ok?

--=20
