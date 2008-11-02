From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd) [SOLVED]
Date: Sun, 2 Nov 2008 03:56:43 -0200
Message-ID: <490d4120.0807c00a.32d8.5eaf@mx.google.com>
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
Received: from yx-out-2324.google.com ([74.125.44.30]:26665 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909AbYKBF4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 01:56:50 -0400
Received: by yx-out-2324.google.com with SMTP id 8so801374yxm.1
        for <netdev@vger.kernel.org>; Sat, 01 Nov 2008 22:56:49 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810301232360.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Oct 2008 12:43:05 +0200 (EET)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Perhaps we could try to solve it though stracing syslogd...

	Well Ilpo, you're right, what I'm about to write here will make
me very ashamed, but the truth must be told! The culprit was syslogd!
Almost unbeliavable, but I had been using and old syslogd version for
about 5 years!

	How can I'm sure that it's syslogd's fault? Simply, because I
had a stall today and when I killed syslogd everything was back to
normal.

	Well, I reinstalled GNU inetutils 1.5 (which I had already
installed before), but I don't know why it put syslogd
in /usr/local/libexec directory.

	But no problem. I'll just wait a few more days to test if
syslogd is the only responsible for this, but I'm 90% sure it is.

	So, just posting this, so if someone, who knows, some day, have
a similar problem, can read this message and avoid all the problems I
had.

	I apologize for thinking that it was a kernel fault. Anyway,
one more lesson I learned: do not keep old binaries lying around... ;)

	Thanks everyone, mainly Ilpo for giving me all tools to reach=20
to this point.

	Ps: just for curiosity, I was using a syslogd binary from Mar,
3, 2003! Extremely old! This is so old, it was compiled for Linux
2.2.5. Or maybe I was too lazy and copied it from another machine...

syslogd: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), for
GNU/Linux 2.2.5, dynamically linked (uses shared libs), not stripped

	Ps2: I'll close the bug I opened on bugzilla.

	Ps3: anyway, it's interesting how a small piece of the system
(syslogd) can generate those kinds of problems... I mean, a simple
error on syslogd could lead to a complete stall on connections, just
because everything is waiting for it to log through /dev/log. Of course
the problem was the binary, but it could have a time out, so even if it
was in fact a buggy syslogd, it won't cause such a stall on the
system. I really don't know what changed from 2.6.24 to 2.6.25, but
maybe 2.6.24 had such a timeout? Maybe I'm just silly writing that...
you guys know much more than me.

	Ps4: maybe now we can understand why nmap solved the issue...

--=20
