From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH v2] can: SJA1000: generic OF platform bus driver
Date: Tue, 26 May 2009 10:10:30 +0100
Message-ID: <200905261010.31364.arnd@arndb.de>
References: <4A16BAAE.3070401@grandegger.com> <200905242327.15139.arnd@arndb.de> <4A1A418D.3040207@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	devicetree-discuss@ozlabs.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:49287 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753409AbZEZJL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 05:11:57 -0400
In-Reply-To: <4A1A418D.3040207@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 25 May 2009, Wolfgang Grandegger wrote:
> > Right, that makes sense. However, most drivers use the field to store the
> > physical address, not the iomap token. Maybe there should be a new field
> > in struct sja1000_priv for the virtual address, but that would be a change
> > to the base driver, not just to the OF portion.
> 
> Is that common practice? If yes, I will add a member to store the
> virtual address to struct sja1000_priv.

I grepped through the network driver for usage of ->base_addr, and
it's somewhat inconsistent. The majority of the users use it for
a physical address, but there are also a few that use it for the
__iomem token.

Casts between unsigned long and qualified (__iomem, __user, const, ...)
pointers do not cause a warning, but can easily lead to bugs when
another user casts to an unqualified pointer.

	Arnd <><

