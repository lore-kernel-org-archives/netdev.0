From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] sky2: EEPROM read/write bug fixes
Date: Sun, 31 Aug 2008 21:35:58 +0100
Message-ID: <20080831203556.GR7908@solarflare.com>
References: <20080827204626.4b65862f@extreme> <20080828111323.GI7908@solarflare.com> <20080828083035.7c6f8f42@extreme> <20080830080342.3733190f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:48028 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757443AbYHaUgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 16:36:10 -0400
Content-Disposition: inline
In-Reply-To: <20080830080342.3733190f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 28 Aug 2008 08:30:35 -0700
> Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> 
> > On Thu, 28 Aug 2008 12:13:25 +0100
> > Ben Hutchings <bhutchings@solarflare.com> wrote:
> > 
> > > Stephen Hemminger wrote:
> > > > Cleanup and harden the routines accessing the EEPROM.
> > > >   1. Prevent spin forever waiting for the TWSI bus
> > > >   2. Fix write eeprom to write full words rather than only 16 bits 
> > > >     Luckly the vendor doesn't provide EEPROM in Linux format so it must never
> > > >     have been used.
> > > >   3. Don't allow partial eeprom writes, not needed, not safe.
> > > [...]
> > > 
> > > You should be able to replace the VPD access code with calls through
> > > pci_dev->vpd->ops - though you'd need to remove some declarations from
> > > drivers/pci/pci.h to include/linux/pci.h.
> > > 
> > > Ben.
> > > 
> > 
> > Generically a good idea, but it won't work for this device.
> > It turns out that the read/write timeouts in pci/access.c are too
> > short. Since the pci vpd code spins under spin lock with irq's disabled,
> > it really can't wait for up to 10ms!
> 
> You can show that the pci->vpd code won't work because any access to
> /sys/class/net/eth0/device/vpd gets ETIMEDOUT.

Then please change the time limit.  There is no time limit for VPD in the
PCI spec so I started with a value that I knew was enough for our devices.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
