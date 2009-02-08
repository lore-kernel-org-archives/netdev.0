From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: 3c509 resume from hibernation broken somewhere between 2.6.25 and 2.6.28
Date: Sun, 8 Feb 2009 21:08:35 +0100
Message-ID: <200902082108.37180.linux@rainbow-software.org>
References: <200902061422.14746.linux@rainbow-software.org> <20090206.220426.21894163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atlantis.sk ([80.94.52.35]:59647 "EHLO mail.atlantis.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752228AbZBHUIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Feb 2009 15:08:44 -0500
In-Reply-To: <20090206.220426.21894163.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 07 February 2009 07:04:26 David Miller wrote:
> From: Ondrej Zary <linux@rainbow-software.org>
> Date: Fri, 6 Feb 2009 14:22:13 +0100
>
> > Hello,
> > last year, I posted a patch which fixed hibernation on 3c509 cards. That
> > was back in 2.6.24. It worked fine in 2.6.25. But then I stopped using
> > hibernation (as it did not work with my new IT8212 RAID controller).
> >
> > Now I fixed it and noticed that 3c509 does not wake up properly anymore
> > (in 2.6.28) - neither in PnP nor in ISA modes. ifconfig down/up makes the
> > card work again in PnP mode. However, in ISA mode, ifconfig up ends with
> > "No such device" error.
> >
> > Comparing the 3c509 driver between 2.6.25 and 2.6.28, there's only some
> > statistics-related change. So the cause of the problem must be somewhere
> > else.
> >
> > This patch makes the resume work in PnP mode, but it's still not enough
> > for ISA mode.
>
> Patch applied, thank you.
>
> Let us know if you figure out how to get the ISA case working
> too :-)

Found that when the driver is compiled as module, ISA resume works fine. But 
when the driver is compiled in the kernel, it does not work. I'm unable to 
find why.

When resuming, el3_isa_resume() is called first. It then calls 
el3_isa_id_sequence(). This function fails when the driver is compiled-in 
because id_read_eeprom(7) returns 0xFFFF - as if the card is not present 
there. I'm out of ideas.

-- 
Ondrej Zary
