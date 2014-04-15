From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [linux-sunxi] Re: [PATCH 7/7] ARM: sun7i: cubietruck: enable
 bluetooth module
Date: Tue, 15 Apr 2014 17:18:08 +0100
Message-ID: <20140415171808.6d60d134@alan.etchedpixels.co.uk>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
	<1397544101-18135-8-git-send-email-wens@csie.org>
	<20140415144215.GG3207@lukather>
	<CAGb2v643HyvFdhQ0znreB8ENXHWpcx6tFwdeU7VuU8KYWcT4ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-sunxi <linux-sunxi@googlegroups.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	Alexandre Courbot <gnurou@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	linux-gpio@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	devicetree <devicetree@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Chen-Yu Tsai <wens@csie.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:45021 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbaDOQTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 12:19:23 -0400
In-Reply-To: <CAGb2v643HyvFdhQ0znreB8ENXHWpcx6tFwdeU7VuU8KYWcT4ZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> For our use case here, which is a bluetooth chip connected on the UART,
> there is no in kernel representation or driver to tie them to. Same goes
> for UART based GPS chips. They just so happen to require toggling a GPIO,
> and maybe enabling a specific clock, to get it running. Afterwards,
> accessing it is done solely from userspace. For our Broadcom chips, the
> user has to upload its firmware first, then designate the tty as a Bluetooth
> HCI using hciattach.

Somewhat similar on some ordinary PC systems. ACPI describes the
properties there but the same things apply - its a device mostly
controlled by a blob of userspace and having a bunch of GPIO lines that
do stuff like turn it on and off.

Is there any reason for not describing it properly and letting the
userspace code fish it out of the devicetree ?

There's no fundamental reason that it's magically different because of
the location of the driver. Given in a few cases we have a choice of
kernel or user space devices for the same hardware thats even more true ?

Failing that we have a long standing proposal never implemented for
adding GPIO awareness to the tty layer. There are a few other use
cases for it including gpio widgets with serial and either some of the
modem lines hacked in via GPIO or with additional control lines for
stuff like smartcard reading interfaces.

https://lkml.org/lkml/2012/5/16/288

In hindsight I'd do it slightly differently and make each "gpio" a pair
of values (purpose,number).

Alan
