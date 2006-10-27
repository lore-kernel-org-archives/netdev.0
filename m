From: James Lentini <jlentini@netapp.com>
Subject: Re: [openib-general] [PATCH 1/9] NetEffect 10Gb RNIC Driver: kernel
 Kconfig and makefiles
Date: Fri, 27 Oct 2006 10:39:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610271031200.28878@jlentini-linux.nane.netapp.com>
References: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EAF@venom2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14451 "EHLO mx2.netapp.com")
	by vger.kernel.org with ESMTP id S1946475AbWJ0OjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 10:39:22 -0400
To: Glenn Grundstrom <ggrundstrom@NetEffect.com>
In-Reply-To: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EAF@venom2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 26 Oct 2006, Glenn Grundstrom wrote:

> diff -ruNp old/drivers/infiniband/hw/nes/Makefile
> new/drivers/infiniband/hw/nes/Makefile
> --- old/drivers/infiniband/hw/nes/Makefile	1969-12-31
> 18:00:00.000000000 -0600
> +++ new/drivers/infiniband/hw/nes/Makefile	2006-10-25
> 11:10:26.000000000 -0500
> @@ -0,0 +1,27 @@
> +EXTRA_CFLAGS += -Idrivers/infiniband/include
> -Idrivers/infiniband/hw/nes/nes_tcpip/include
> +
> +ifdef CONFIG_INFINIBAND_NES_DEBUG
> +EXTRA_CFLAGS += -DNES_DEBUG
> +endif

The NES_DEBUG flag is unnecessary. You can check for 
CONFIG_INFINIBAND_NES_DEBUG in the code. See 
CONFIG_INFINIBAND_MTHCA_DEBUG for an example.

> +
> +ifneq ($(KERNELRELEASE),)
> +	obj-$(CONFIG_INFINIBAND_NES) += iw_nes.o	
> +
> +	iw_nes-objs := \
> +		nes.o \
> +		nes_hw.o \
> +		nes_nic.o \
> +		nes_cm.o \
> +		nes_utils.o \
> +		nes_verbs.o 
> +else
> +	KERNELDIR ?= /usr/src/linux
> +	PWD := $(shell pwd)
> +
> +default:
> +	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
> +
> +clean:
> +	$(MAKE) -C $(KERNELDIR) M=$(PWD) clean
> +
> +endif

In tree drivers don't provide support for out-of-tree builds. See 
drivers/infiniband/hw/mthca/Makefile for an example of how to 
simplify this.
