From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH staging] Add SBE 2T3E3 WAN driver
Date: Sat, 31 Jul 2010 12:53:35 -0700
Message-ID: <20100731195335.GB4644@kroah.com>
References: <m3ocdoasen.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:59780 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948Ab0GaTwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 15:52:45 -0400
Content-Disposition: inline
In-Reply-To: <m3ocdoasen.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 31, 2010 at 11:53:52AM +0200, Krzysztof Halasa wrote:
> This is a driver for SBE Inc.'s dual port T3/E3 WAN cards. Based on
> their original GPLed driver.
> It needs at least a new generic HDLC setup code (not yet written) before
> moving to drivers/net/wan.
> 
> Signed-off-by: Krzysztof Ha??asa <khc@pm.waw.pl>
> 
> ---
> I have generated the patch against v2.6.35-rc6. Compiles cleanly.
> Please let me know if it needs extra changes for e.g. staging tree.
> Thanks.
> 
>  drivers/staging/Kconfig              |    2 +
>  drivers/staging/Makefile             |    1 +
>  drivers/staging/sbe-2t3e3/2t3e3.h    |  896 ++++++++++++++++++++++++++++++++++
>  drivers/staging/sbe-2t3e3/Kconfig    |   13 +
>  drivers/staging/sbe-2t3e3/Makefile   |    4 +
>  drivers/staging/sbe-2t3e3/cpld.c     |  366 ++++++++++++++
>  drivers/staging/sbe-2t3e3/ctrl.c     |  363 ++++++++++++++
>  drivers/staging/sbe-2t3e3/ctrl.h     |  131 +++++
>  drivers/staging/sbe-2t3e3/dc.c       |  507 +++++++++++++++++++
>  drivers/staging/sbe-2t3e3/exar7250.c |  217 ++++++++
>  drivers/staging/sbe-2t3e3/exar7300.c |  182 +++++++
>  drivers/staging/sbe-2t3e3/intr.c     |  651 ++++++++++++++++++++++++
>  drivers/staging/sbe-2t3e3/io.c       |  352 +++++++++++++
>  drivers/staging/sbe-2t3e3/main.c     |  171 +++++++
>  drivers/staging/sbe-2t3e3/maps.c     |  104 ++++
>  drivers/staging/sbe-2t3e3/module.c   |  210 ++++++++
>  drivers/staging/sbe-2t3e3/netdev.c   |  142 ++++++
>  include/linux/pci_ids.h              |    3 +

First off, read the top of the pci_ids.h file, which says to not add new
entries that are only used in a single driver.

Secondly, why have this as a staging driver?  What is lacking in it to
get it merged into the main kernel tree as a "normal" driver?  Hint, you
need a TODO file in the driver directory that lists the things left to
be done to it to get it merged, and a name/email address to send the
patches to.

> +++ b/drivers/staging/sbe-2t3e3/2t3e3.h
> @@ -0,0 +1,896 @@
> +/*
> + * SBE 2T3E3 synchronous serial card driver for Linux
> + *
> + * Copyright (C) 2009-2010 Krzysztof Halasa <khc@pm.waw.pl>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of version 2 of the GNU General Public License
> + * as published by the Free Software Foundation.
> + *
> + * This code is based on a driver written by SBE Inc.

What driver would that have been?  If it's based on someone else's work,
it's nice to mention the copyright holders of that work you based yours
on.

> + */
> +
> +#ifndef T3E3_H
> +#define T3E3_H
> +
> +#include <linux/hdlc.h>
> +#include <linux/interrupt.h>
> +#include <linux/netdevice.h>
> +#include <linux/pci.h>
> +#include <linux/io.h>
> +#include "ctrl.h"
> +
> +#define DRV_NAME "SBE 2T3E3"

spaces and all caps isn't the nicest thing for linux drivers, it does
odd things in sysfs for some scripts (the space thing, not the
uppercase.)


thanks,

greg k-h
