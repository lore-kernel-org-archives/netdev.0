From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/2] sky2: EEPROM read/write bug fixes
Date: Thu, 28 Aug 2008 08:30:35 -0700
Message-ID: <20080828083035.7c6f8f42@extreme>
References: <20080827204626.4b65862f@extreme>
	<20080828111323.GI7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44743 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752421AbYH1Pbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 11:31:33 -0400
In-Reply-To: <20080828111323.GI7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Aug 2008 12:13:25 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> Stephen Hemminger wrote:
> > Cleanup and harden the routines accessing the EEPROM.
> >   1. Prevent spin forever waiting for the TWSI bus
> >   2. Fix write eeprom to write full words rather than only 16 bits 
> >     Luckly the vendor doesn't provide EEPROM in Linux format so it must never
> >     have been used.
> >   3. Don't allow partial eeprom writes, not needed, not safe.
> [...]
> 
> You should be able to replace the VPD access code with calls through
> pci_dev->vpd->ops - though you'd need to remove some declarations from
> drivers/pci/pci.h to include/linux/pci.h.
> 
> Ben.
> 

Generically a good idea, but it won't work for this device.
It turns out that the read/write timeouts in pci/access.c are too
short. Since the pci vpd code spins under spin lock with irq's disabled,
it really can't wait for up to 10ms!

Minor note: the pci code seems to be much more verbose with little
gain in real functionality.
