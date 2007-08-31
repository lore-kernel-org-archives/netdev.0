From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/7] Generic bitbanged MDIO library
Date: Fri, 31 Aug 2007 09:23:04 -0400
Message-ID: <46D81638.6050509@pobox.com>
References: <20070817175357.GA9218@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Paul Mackerras <paulus@samba.org>
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36656 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965031AbXHaNXJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:23:09 -0400
In-Reply-To: <20070817175357.GA9218@ld0162-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Scott Wood wrote:
> Previously, bitbanged MDIO was only supported in individual
> hardware-specific drivers.  This code factors out the higher level
> protocol implementation, reducing the hardware-specific portion to
> functions setting direction, data, and clock.
> 
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> ---
>  drivers/net/phy/Kconfig        |    9 ++
>  drivers/net/phy/Makefile       |    1 +
>  drivers/net/phy/mdio-bitbang.c |  187 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/mdio-bitbang.h   |   42 +++++++++
>  4 files changed, 239 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/phy/mdio-bitbang.c
>  create mode 100644 include/linux/mdio-bitbang.h

I cannot ACK this, nor do I want to see it merged, until users appear 
and have been reviewed alongside this.  I do not see any fs_enet patches 
that actually use this.

five-second-glance comments:

* "mdio_bitbang_" is a long prefix.  consider "mdiobb_" or somesuch

* the delay (where you call ndelay()) is not guaranteed without a flush 
of some sort

* how widely applicable is this "generic" library?  have you converted 
any non-embedded drivers over to it?

