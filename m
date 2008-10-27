From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 1/1] r8169: revert "read MAC address from EEPROM on init"
Date: Mon, 27 Oct 2008 15:49:48 +0100
Message-ID: <m33aii5bzn.fsf@maximus.localdomain>
References: <20081026160249.GA25443@electric-eye.fr.zoreil.com>
	<m3wsfvhx8c.fsf@maximus.localdomain>
	<20081026222224.GC24790@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>, jgarzik@pobox.com,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alistair John Strachan <alistair@devzero.co.uk>,
	Ivan Vecera <ivecera@redhat.com>,
	Chuck Ebbert <cebbert@redhat.com>,
	Petr Vandrovec <petr@vandrovec.name>,
	Plamen Petrov <pvp-lsts@fs.ru.acad.bg>,
	Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>,
	"J.A. Magall\?n" <jamagallon@ono.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	Simon Arlott <simon@fire.lp0.eu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752138AbYJ0OuL@vger.kernel.org>
In-Reply-To: <20081026222224.GC24790@electric-eye.fr.zoreil.com> (Francois Romieu's message of "Sun\, 26 Oct 2008 23\:22\:24 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> writes:

> In practice I noticed rather different behaviors between a 8168b and
> a 8110s when I tried accessing the eeprom through plain old bitbang
> a few months ago (i.e. ok on the 8110, lots of zero on the 8168b).

You mean "manually" controlling EEPROM clock and data lines, using
a different register?
A speed issue by chance?

If they have a different way to write to the EEPROM (using direct
access to EEPROM signals), then perhaps there is no EEPROM write mode
using VPD? VPD write mode (not writing to the address/F register, but
writing to VPD "storage" itself) is quite simple and permanent, thus
kind of dangerous. If it's R/O, then it can't erase the EEPROM (parts).

>> I wonder if changing the MAC address by hand works (using ifconfig, to
>> arbitrary address).
>
> It does. It can be quite sticky. That was the whole point of the
> patch.

I see.

I wouldn't drop this patch permanently, though.
-- 
Krzysztof Halasa
