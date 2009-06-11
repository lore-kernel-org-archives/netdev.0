From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
	configuration.
Date: Thu, 11 Jun 2009 20:31:59 +0100
Message-ID: <1244748719.2785.72.camel@achroite>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
	 <1244685768.4616.22.camel@deadeye> <4A30A884.9000508@gmail.com>
	 <1244732090.2785.12.camel@achroite>
	 <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
	 <1244739166.2785.52.camel@achroite>
	 <alpine.LFD.2.00.0906111333100.31536@xanadu.home>
	 <1244744967.2785.61.camel@achroite>
	 <alpine.LFD.2.00.0906111452340.31536@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mfuzzey@gmail.com, netdev@vger.kernel.org
To: Nicolas Pitre <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:46493 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755074AbZFKTcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 15:32:04 -0400
In-Reply-To: <alpine.LFD.2.00.0906111452340.31536@xanadu.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-06-11 at 15:08 -0400, Nicolas Pitre wrote:
[...]
> > Please note, I'm talking about an init script -
> > which you surely must have - not an initramfs, which I recognise is
> > optional and unnecessary for most embedded systems.
>=20
> An init script is already a luxury for some systems.

And so is an Ethernet port.  Instead of talking about hypotheticals, wh=
y
not talk about the system you need this workaround for?

> It means a=20
> script, which implies a shell, and of course the tool binaries (ethto=
ol=20
> in this case) to be called by your shell.  Not only those do bloat yo=
ur=20
> system (the shell + tool + script occupies way more space than the=20
> proposed module)

Well, if you're replacing init - which is generally a really bad idea,
by the way - you can build the ethtool API calls in there along with al=
l
your other application-specific stuff.  The ethtool API isn't terribly
complex.

> and then you do have to maintain those components as=20
> well, but it also has impact on boot time.  Remember that we're not=20
> talking about systems bragging about their boot time being under 20=20
> seconds here, but systems that need to be operational in only a coupl=
e=20
> miliseconds.

If you want to boot that quickly you definitely don't want to have to
wait for PHY operations.

> > =EF=BB=BFI was thinking that you could add it to the platform data =
for such
> > devices, not that you would put board-specific quirks in the driver=
s.
>=20
> And what if the majority of users for a driver simply don't need such=
 a=20
> thing?  And how do you do that if the driver you need is for a PCI=20
> device?

Any device can have platform data; it's part of struct device.

> And why would driver specific kirks be better than a generic=20
> module that can handle those params in a uniform way across all drive=
rs? =20
> Especially if you can ignore said module if you don't need/want to us=
e=20
> it?

Because its raison d'etre is apparently to disable the broken link
modes, and it doesn't do that properly.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

