From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/9] NetEffect 10Gb RNIC Driver: kernel Kconfig and makefiles
Date: Thu, 26 Oct 2006 16:58:41 -0700
Message-ID: <adawt6m634e.fsf@cisco.com>
References: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EAF@venom2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <openib-general@openib.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:30242 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S1946029AbWJZX6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 19:58:43 -0400
To: <glenng@NetEffect.com>
In-Reply-To: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EAF@venom2> (Glenn Grundstrom's message of "Thu, 26 Oct 2006 18:45:39 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +source "drivers/infiniband/hw/nes/Kconfig"
 > +
 >  source "drivers/infiniband/hw/cxgb3/Kconfig"

This patch seems to be against some non-standard tree, since cxgb3
isn't upstream yet.  And if cxgb3 were already upstream, it might be
polite to add yourself after it rather than before ;)

 > +config INFINIBAND_NES_DEBUG
 > +	bool "Verbose debugging output"
 > +	depends on INFINIBAND_NES
 > +	default n
 > +	---help---
 > +	  This option causes the NetEffect RNIC driver to produce debug
 > +	  messages.  Select this if you are developing the driver
 > +	  or trying to diagnose a problem.

I recommend making this option invisible unless EMBEDDED is set, and
having the default be 'y', and making your debugging level changeable
at run-time.  That way everyone (in particular distros) will have this
turned on and you'll be able to figure out problems without making
end-users rebuild a kernel.

 > +EXTRA_CFLAGS += -Idrivers/infiniband/include

Not needed in the kernel tree.

 > -Idrivers/infiniband/hw/nes/nes_tcpip/include

I guess this is the mysterious TCP stack module.  Anyway if you need
this in the end, I would suggest removing the C flag and using
#include "nes_tcpip/blah.h" in your source.

 > +ifdef CONFIG_INFINIBAND_NES_DEBUG
 > +EXTRA_CFLAGS += -DNES_DEBUG
 > +endif

There's no point to this -- just test CONFIG_INFINIBAND_NES_DEBUG directly.

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

This should be your whole Makefile -- we're not going to merge stuff
into the kernel tree to build your module out of the kernel tree.
Also it's more idiomatic to put all your component objects onto one
(or a few) lines.

 - R.
