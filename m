From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 4/7] mfd: add MFD based flexcard driver
Date: Wed, 14 Aug 2013 10:45:28 +0100
Message-ID: <20130814094528.GC4046@lee--X1>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
 <1376384922-8519-6-git-send-email-b.spranger@linutronix.de>
 <20130813095508.GA5109@lee--X1>
 <20130814101247.3ad43494@mitra.spranger.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Holger Dengler <dengler@linutronix.de>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:50194 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567Ab3HNJpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 05:45:35 -0400
Received: by mail-ea0-f173.google.com with SMTP id g10so4694936eak.4
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 02:45:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130814101247.3ad43494@mitra.spranger.biz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Wow, this is a huge patch which is going to be an insanely long,
> > laborious and complex task to review it all.
> This is a card with a "insane" amount of features:
>=20
> 1) a Interrupt controller
> 2) a DMA engine
> 3) up to 8 CAN devices
> 4) up to 4 FlexRay devices
> 5) a dozen different trigger sources
> 6) timer
> 7) timestamp counter

Right. Even more reason for the the patch to be broken up into many.

> > Can you split this up into many patches?
> Not sure how to split this up into a smaller and workable series of p=
atches.
> Maybe rip out the header and the DMA part into a separate patch.

I was thinking more along the lines of:

    Patch 1: Basic compilation support
     - Core driver Kconfig entry
     - Introduction of the core driver
       - Basic probe(): memory allocation, register as MFD device
       - Basic remove(): unregister as MFD device
   =20
    Patch 2: Basic PCI support
     - pci_enable_device()
     - pci_request_regions()
     - Memory mapping
   =20
    Patch 3:
     - fc_init_dma()
   =20
    Patch 4:
     - fc_init_uio()
   =20
    Patch 5:
     - fc_init_event()
   =20
    Patch 6:
     - fc_init_clk()
   =20
    Patch 7:
     - fc_init_bus()
   =20
    Patch 8 - 8+n: Start adding sysfs entries
   =20
    Patch 8+n+1: Basic IRQ support
   =20
    Etc etc etc

Remember, the smaller the patches, the more chance that they'll be
accepted. I already see quite a few issues with this patch. Breaking
it up will allow for more thorough review and finer grain feedback.

Issues I see after first glance:

  - Lack of Device Tree support
  - Lack of documentation for new sysfs entries
  - Different IRQs with same .name property
  - Memory allocations and mapping should be managed (devm_*)

--=20
Lee Jones
Linaro ST-Ericsson Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
