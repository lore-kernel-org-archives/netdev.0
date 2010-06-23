From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] phylib: Add autoload support for the LXT973 phy.
Date: Wed, 23 Jun 2010 10:00:12 +0100
Message-ID: <1277283612.16262.195.camel@macbook.infradead.org>
References: <20100531130932.GA15845@riccoc20.at.omicron.at>
	 <1277210293.21798.11.camel@localhost>
	 <20100623053723.GA3404@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57956 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256Ab0FWJAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 05:00:14 -0400
In-Reply-To: <20100623053723.GA3404@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-23 at 07:37 +0200, Richard Cochran wrote:
> 
> Question about the whole PHY MODULE_DEVICE_TABLE system:
> 
> I recently posted a phy driver for the National Semiconductor
> DP83640. During development, I used drivers/net/arm/ixp4xx_eth.c as
> the MAC driver, which was linked into the kernel (not a module). I
> noticed that the phy driver's probe function only gets called if the
> phy driver is also statically linked, but not when it is loaded as a
> module.
>
> Is this the correct behavior? 

Hm, that seems like the _expected_ behaviour, certainly. The MAC driver
will probe its device at boot time, and will issue a request_module() to
load the a specific PHY driver if there is one. When no such module
turns up (which it won't if you have no file system mounted yet), it'll
just fall back to the generic PHY support.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

