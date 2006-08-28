From: Brent Cook <bcook@bpointsys.com>
Subject: Re: e1000: operation without eeprom?
Date: Mon, 28 Aug 2006 09:20:08 -0500
Message-ID: <200608280920.08647.bcook@bpointsys.com>
References: <20060828005019.GA31786@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tbm@cyrius.com, yt_lee@thecus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 70-253-197-251.ded.swbell.net ([70.253.197.251]:2838 "EHLO
	bpointsys.com") by vger.kernel.org with ESMTP id S1750940AbWH1OT5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 10:19:57 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20060828005019.GA31786@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 27 August 2006 19:50, Lennert Buytenhek wrote:
> Hi,
>
> There are a couple of ARM boards out there with on-board e1000s but
> without any kind of eeprom.  The boot loader and kernel board support
> code have all the info necessary to configure the e1000, but the e1000
> driver bombs out because there isn't an eeprom connected -- how are
> we supposed to deal with this situation?
>

u-boot, which uses modified versions of the linux e1000 drivers, handles this 
special cases with a bunch of platform-specific #ifdefs

http://www.denx.de/cgi-bin/gitweb.cgi?p=u-boot.git;a=blob;h=927acbb26737a20e02962f67047e192545a870a1;hb=16850919ff8666f20d047cb83b4ee77581336515;f=drivers/e1000.c

I fear that working in general across the e1000 product line without an eeprom 
might not work so well. We've had 82545's work OK without and eeprom, but the 
82572 did not work so well. Some chips appear to work OK with pure software 
config, whereas others might need some special setup parameters that would 
work best at chip power-up via the eeprom.

As a general solution (with fewer ifdefs than the u-boot solution), it might 
be nice to have a read_eeprom_virtual(..) method in the driver where one 
could supply a binary blob to the driver instead of having a real eeprom. All 
of the driver code that relies on the eeprom could work like normal. I've 
been toying with this under u-boot for a custom ARM board without an eeprom 
too, though it does have the side-effect of bloating the u-boot driver a bit 
with the fake eeprom data that's really useless after boot (it's mostly 
0xFFFFFFFF's though, so you could totally optimize it.)

 - Brent
