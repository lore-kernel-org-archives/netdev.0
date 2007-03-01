From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH -mm 3/5] Blackfin: on-chip ethernet MAC controller driver
Date: Thu, 1 Mar 2007 13:21:27 -0500
Message-ID: <8bd0f97a0703011021s3d74b129yaa59ce65142115e0@mail.gmail.com>
References: <1172722514.5264.77.camel@roc-desktop>
	 <45E6F6D6.5000804@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bryan.wu@analog.com, "Andrew Morton" <akpm@linux-foundation.org>,
	jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:17399 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965482AbXCASV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 13:21:27 -0500
Received: by an-out-0708.google.com with SMTP id b33so464629ana
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2007 10:21:27 -0800 (PST)
In-Reply-To: <45E6F6D6.5000804@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/1/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> Wu, Bryan wrote:
> > +config BFIN_MAC
> > +     tristate "Blackfin 536/537 on-chip mac support"
> > +     depends on NET_ETHERNET && (BF537 || BF536) && (!BF537_PORT_H)
> > +     select CRC32
> > +     select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
> > +     help
> > +       This is the driver for blackfin on-chip mac device. Say Y if you want it
> > +       compiled into the kernel. This driver is also available as a module
> > +       ( = code which can be inserted in and removed from the running kernel
> > +       whenever you want). The module will be called bfin_mac.
> > +
> > +config BFIN_MAC_USE_L1
> > +     bool "Use L1 memory for rx/tx packets"
> > +     depends on BFIN_MAC && BF537
> > +     default y
> > +     help
> > +       To get maximum network performace, you should use L1 memory as rx/tx buffers.
> > +       Say N here if you want to reserve L1 memory for other uses.
> > +
> > +config BFIN_TX_DESC_NUM
> > +     int "Number of transmit buffer packets"
> > +     depends on BFIN_MAC
> > +     range 6 10 if BFIN_MAC_USE_L1
> > +     range 10 100
> > +     default "10"
> > +     help
> > +       Set the number of buffer packets used in driver.
> > +
> > +config BFIN_RX_DESC_NUM
> > +     int "Number of receive buffer packets"
> > +     depends on BFIN_MAC
> > +     range 20 100 if BFIN_MAC_USE_L1
> > +     range 20 800
> > +     default "20"
> > +     help
> > +       Set the number of buffer packets used in driver
> >
> The regular practice is to put these in a device include file, and not
> make them kernel configurable.

we're working on moving some of this stuff into the board files rather
than Kconfig

> Why would you want to make it tuneable at compile time?

because it was easier to implement and deploy the first time around ;)
-mike
