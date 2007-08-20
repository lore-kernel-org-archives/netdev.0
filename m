From: Erik Slagter <erik@slagter.name>
Subject: Re: Linksys Gigabit USB2.0 adapter (asix) regression
Date: Mon, 20 Aug 2007 18:23:14 +0200
Message-ID: <46C9BFF2.8030206@slagter.name>
References: <467915D9.3030900@slagter.name>	<1182523020.4938.20.camel@dhollis-lnx.sunera.com>	<467FF5DB.5090006@slagter.name>	<1182923692.6644.4.camel@dhollis-lnx.sunera.com>	<46ADAF1B.4060500@slagter.name>	<1185820074.8086.4.camel@dhollis-lnx.sunera.com>	<46B4A826.7010705@slagter.name> <1186603993.3078.16.camel@dhollis-lnx.sunera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Hollis <dhollis@davehollis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from erik-slagter.demon.nl ([83.160.41.216]:40387 "EHLO
	artemis.slagter.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759508AbXHTQY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 12:24:58 -0400
In-Reply-To: <1186603993.3078.16.camel@dhollis-lnx.sunera.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Hollis wrote:

> It's a bit of a longshot, but I notice that EEPROM index 0x17 returns
> 0x580 for you, 0x180 for my devices.  Based on that, my devices go
> through the "gpio phymode == 1 path" GPIO init sequence, and yours goes
> through the other path (  if ((eeprom >> 8) != 1) { ).  Comment out the
> if() else portion so that you go through the "phymode == 1" path and see
> if that makes a difference.  That segment should look something like
> this:
> 
> /*
>         if ((eeprom >> 8) != 1) {
>                 asix_write_gpio(dev, 0x003c, 30);
>                 asix_write_gpio(dev, 0x001c, 300);
>                 asix_write_gpio(dev, 0x003c, 30);
>         } else {
> */
>                 dbg("gpio phymode == 1 path");
>                 asix_write_gpio(dev, AX_GPIO_GPO1EN, 30);
>                 asix_write_gpio(dev, AX_GPIO_GPO1EN | AX_GPIO_GPO_1,
> 30);
> //      }

Tried, but now it doesn't work at all, no LEDs and no traffic.
