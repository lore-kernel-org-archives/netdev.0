From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] EEPROM dumping/changing code for r8169 driver
Date: Sun, 21 Jul 2013 21:12:13 +0100
Message-ID: <1374437533.2804.71.camel@deadeye.wl.decadent.org.uk>
References: <1906856.2MoFjQXLhS@al>
	 <1374422514.2804.4.camel@deadeye.wl.decadent.org.uk>
	 <3011523.vtKLIuqRfe@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	"Realtek linux nic maintainers" <nic_swsd@realtek.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7657 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756041Ab3GUUMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 16:12:17 -0400
In-Reply-To: <3011523.vtKLIuqRfe@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-07-21 at 18:27 +0200, Peter Wu wrote:
> On Sunday 21 July 2013 17:01:54 Ben Hutchings wrote:
> > On Fri, 2013-07-19 at 11:48 +0200, Peter Wu wrote:
> > > Hi,
> > > 
> > > As noted in another mail, I have been working on adding EEPROM reading
> > > writing support for the r8169 driver. The below diff adds basic support,
> > > but it
> > > is not completely finished yet:
> > [...]
> > 
> > > --- a/drivers/net/ethernet/realtek/Kconfig
> > > +++ b/drivers/net/ethernet/realtek/Kconfig
> > > @@ -112,4 +112,13 @@ config R8169
> > > 
> > >  	  To compile this driver as a module, choose M here: the module
> > >  	  will be called r8169.  This is recommended.
> > > 
> > > +config R8169_93CX6
> > > +	bool "Realtek 8169 external 93CX6 EEPROM support"
> > > +	depends on R8169
> > > +	select EEPROM_93CX6
> > 
> > [...]
> > 
> > This select is wrong as it will cause EEPROM_93CX6=y even if R8169=m.
> > But why make this an option at all?
> For this, I got inspiration from drivers/ethernet/8390/Kconfig which had an
> AX88796_93CX6 option. Reading EEPROM is currently not a critical piece of
> functionality, so I decided to make this optional.

Most ethtool operations are not critical, but it costs very little to
implement them unconditionally (and config options increase the
maintenance burden).

> There seem also to be newer
> hardware that use a two-wired serial interface for accessing EEPROM instead of
> 93C46/93C56/93C66. Would you suggest always including this code (distro
> kernels should typically enable this) or making it optional?
[...]

Always include it.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
