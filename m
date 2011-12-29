From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: Allocation of MDIO bus numbers when fixed MDIO bus is enabled?
Date: Thu, 29 Dec 2011 23:10:11 +0400
Message-ID: <20111229191011.GA19220@oksana.dev.rtsoft.ru>
References: <4EFC90C8.1060802@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51900 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888Ab1L2TKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 14:10:16 -0500
Received: by wgbdr13 with SMTP id dr13so23556292wgb.1
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2011 11:10:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4EFC90C8.1060802@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Dec 29, 2011 at 05:09:44PM +0100, Florian Fainelli wrote:
> An user of the r6040 driver has enabled support for the Fixed MDIO
> bus, so when the r6040 registers with its first instance, it will
> also try to register a MDIO bus with id 0, and this fails.
> 
> What's the proper solution to fixing this kind of issue? The same
> user proposed to use the pci slot and function as an id for
> registering the MDIO bus, which will work for PCI devices, but not
> for platform_devices for instance.

AFAIR, MDIO bus id doesn't have to be numeric, so you can change it
to parent's dev_name(). I.e. something like

 snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "%s-mdio", dev_name(dev));

So, the resulting PHYs would have IDs something like "dev-mdio:1".

Thanks,

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com
