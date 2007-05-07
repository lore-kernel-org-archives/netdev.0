From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 3/3] Intel IXP4xx network drivers
Date: Mon, 07 May 2007 19:12:49 +0200
Message-ID: <m3hcqoa772.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3vef5biob.fsf@maximus.localdomain>
	<5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Michael-Luke Jones <mlj28@cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57444 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965662AbXEGRMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 13:12:51 -0400
In-Reply-To: <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk> (Michael-Luke Jones's message of "Mon, 7 May 2007 13:59:26 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael-Luke Jones <mlj28@cam.ac.uk> writes:

> Code placement:
> Queue Manager & NPE code => arch/arm/mach-ixp4xx
> WAN driver code => drivers/net/wan
> Eth code => drivers/net/arm

Why would you want such placement?
Potential problems: header files would have to be moved to
include/asm-arm = headers pollution.
All 4 drivers are, in fact, network (related) drivers.

drivers/net/arm would probably make (some) sense if it was
a single (or not so single) Ethernet driver.

> Kconfig:
> I'm not convinced about 'config IXP4XX_NETDEVICES'. I'd lose it
> together with the drivers/net/ixp4xx directory

It wouldn't make sense without the directory, no doubt.

> Ethernet & HSS code should probably select NPE and QMGR (rather than
> depend)

Actually, that's exactly what this patch do.

> but these options should still be exposed in arch/arm/mach-
> ixp4xx/Kconfig

Why exactly? They are network devices, who would expect them there?
How about the dependency mess (NET_ETHERNET etc.) that would be
created?
-- 
Krzysztof Halasa
