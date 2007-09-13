From: David Miller <davem@davemloft.net>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Wed, 12 Sep 2007 23:57:11 -0700 (PDT)
Message-ID: <20070912.235711.71114960.davem@davemloft.net>
References: <46E7EE89.9060006@katalix.com>
	<20070912160239.70a580e8@oldman>
	<535ddc6b0709120947x3458c87dk7dac9a2b8edf26f6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, jchapman@katalix.com,
	hadi@cyberus.ca, billfink@mindspring.com, netdev@vger.kernel.org,
	jeff@garzik.org, ossthema@de.ibm.com
To: mandeep.baines@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:50980
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760020AbXIMG7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 02:59:35 -0400
In-Reply-To: <535ddc6b0709120947x3458c87dk7dac9a2b8edf26f6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mandeep Baines" <mandeep.baines@gmail.com>
Date: Wed, 12 Sep 2007 09:47:46 -0700

> Why would disabling IRQ's be expensive on non-MSI PCI devices?
> Wouldn't it just require a single MMIO write to clear the interrupt
> mask of the device.

MMIO's are the most expensive part of the whole interrupt
servicing routines and minimizing them is absolutely
crucial.

This is why many devices do things like report status purely
in memory data structures, automatically disable interrupts
on either MSI delivery or status register read, etc.

Often you will see the first MMIO access in the interrupt
handler at the top of the profiles.
