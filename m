From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] r8169: revert "read MAC address from EEPROM on
	init"
Date: Sun, 26 Oct 2008 23:22:24 +0100
Message-ID: <20081026222224.GC24790@electric-eye.fr.zoreil.com>
References: <20081026160249.GA25443@electric-eye.fr.zoreil.com> <m3wsfvhx8c.fsf@maximus.localdomain>
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
	"J.A. Magall?n" <jamagallon@ono.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	Simon Arlott <simon@fire.lp0.eu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58601 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752589AbYJZWZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 18:25:22 -0400
Content-Disposition: inline
In-Reply-To: <m3wsfvhx8c.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa <khc@pm.waw.pl> :
[...]
> Ahh, just PCI VPD.
> 
> IMHO the above shouldn't hurt anyone, in theory. You only write to
> VPD_ADDR, and to change actual VPD data (i.e., EEPROM), you need to
> write to VPD_DATA.
> 
> Anyone should be allowed to do that even for unknown PCI devices
> without a problem.

Theorically, yes.

In practice I noticed rather different behaviors between a 8168b and
a 8110s when I tried accessing the eeprom through plain old bitbang
a few months ago (i.e. ok on the 8110, lots of zero on the 8168b).

> > -static void rtl_init_mac_address(struct rtl8169_private *tp,
> 
> > -	if (!(cfg1  & VPD)) {
> > -		if (netif_msg_probe(tp))
> > -			dev_info(&pdev->dev, "VPD access disabled, enabling\n");
> > -		RTL_W8(Cfg9346, Cfg9346_Unlock);
> > -		RTL_W8(Config1, cfg1 | VPD);
> > -		RTL_W8(Cfg9346, Cfg9346_Lock);
> 
> Now I wonder what do they say the above does exactly.
> Unfortunately the docs don't seem to be public.

Realtek's legal department has changed his mind :o(

>From what I had received beforehand:

RTL8169:  R/W Set to enable Vital Product Data. The VPD data is stored in
          93C46 or 93c56 from within offset 40h-7fh.

RTL8168C: R (huh ?) Set to enable Vital Product Data. Always 1.

[...]
> > -	if (netif_msg_probe(tp)) {
> > -		DECLARE_MAC_BUF(buf);
> > -
> > -		dev_info(&pdev->dev, "MAC address found in EEPROM: %s\n",
> > -			 print_mac(buf, mac));
> > -	}
> > -
> > -	if (is_valid_ether_addr(mac))
> > -		rtl_rar_set(tp, mac);
> > -}
> 
> No RTL_W8(Config1, cfg1 | ~VPD) to disable (perhaps R/W) access?

Apparently not. See above.

> Though obviously first reading a good address from the EEPROM and then
> erasing first 32 bits is a different story.

Yes.

> I wonder if changing the MAC address by hand works (using ifconfig, to
> arbitrary address).

It does. It can be quite sticky. That was the whole point of the
patch.

-- 
Ueimor
