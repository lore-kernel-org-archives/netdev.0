From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 13/26] sfp: add phylink based SFP module support
Date: Thu, 07 Jan 2016 12:23:53 -0800
Message-ID: <568EC959.1080706@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zju-00075n-1n@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33727 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbcAGUY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:24:27 -0500
Received: by mail-pa0-f42.google.com with SMTP id cy9so266901595pac.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:24:27 -0800 (PST)
In-Reply-To: <E1a5zju-00075n-1n@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:38, Russell King wrote:
> Add support for SFP hotpluggable modules via phylink.  This supports
> both copper and optical SFP modules, which require different Serdes
> modes in order to properly negotiate the link.
> 
> Optical SFP modules typically require the Serdes link to be talking
> 1000base-X mode - this is the gigabit ethernet mode defined by the
> 802.3 standard.
> 
> Copper SFP modules typically integrate a PHY in the module to convert
> from Serdes to copper, and the PHY will be configured by the vendor
> to either present a 1000base-X Serdes link (for fixed 1000base-T) or
> a SGMII Serdes link.  However, this is vendor defined, so we instead
> detect the PHY, switch the link to SGMII mode, and use traditional
> PHY based negotiation.

This goes pretty deep into the SFP specs, which I don't have a fresh
memory of, few nits here and there:

include/linux/sfp.h contains things that could be useful for user-space
since these are standard definitions, should this be moved to uapi such
that ethtool could use that header too?
-- 
Florian
