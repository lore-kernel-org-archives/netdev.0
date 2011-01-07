From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Fri, 7 Jan 2011 11:49:37 -0800
Message-ID: <AANLkTikwrHoOY4wvUp1qn-OT=EjZesSNR29US1ERc0o2@mail.gmail.com>
References: <20110106.122003.233698077.davem@davemloft.net>
 <AANLkTi=7=_FyVsjA3vKEpg8RwfC=m-8QGfqa6ctxQday@mail.gmail.com> <20110107190656.GQ3702@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Woodhouse <dwmw2@infradead.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <benh@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43038 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755448Ab1AGTua convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jan 2011 14:50:30 -0500
In-Reply-To: <20110107190656.GQ3702@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 7, 2011 at 11:06 AM, Ben Hutchings <benh@debian.org> wrote:
>
> This is because the driver is requesting firmware during probe, befor=
e
> there is a firmware agent available (maybe even before / is mounted?)
> rather than when the interface is brought up, as many other network
> drivers do.

Yeah, doing it at device up time would fix the problem.

> At the very least, we ought to make firmware loading fail fast and
> noisily if this happens.

Absolutely.
>

> There were some tables of PHY registers to poke that were a mixture o=
f
> control register writes and transfer of firmware to the microcontroll=
er.
> Hayes and Francois have separated those out.

Ok.

>> I bet I can make it work by making it a module, and installing the
>> firmware manually. But it's supposed to work even without that.
>
> Right. =A0This is very vaguely based on a patch I applied in Debian
> where we build r8169 as a module, and I don't think anyone reported
> this behaviour.

I just confirmed that building it as a module works

[ Apart from the annoyance of also having to manually copying the
firmware files: why the heck doesn't that firmware tree even have a
"make firmware-install" makefile or something? The kernel has a "make
firmware-install" thing, why doesn't the firmware tree itself have
that? Gaah, this is almost as idiotic as trying to install a
self-built kernel under Ubuntu ]

                        Linus
