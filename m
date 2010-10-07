From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] net: allow FEC driver to not have attached PHY
Date: Thu, 07 Oct 2010 14:11:11 +0100
Message-ID: <1286457071.2271.4.camel@achroite.uk.solarflarecom.com>
References: <201010070350.o973oGFE026910@goober.internal.moreton.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerg@uclinux.org
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8383 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760537Ab0JGNLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 09:11:14 -0400
In-Reply-To: <201010070350.o973oGFE026910@goober.internal.moreton.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-10-07 at 13:50 +1000, Greg Ungerer wrote:
> Hi All,
> 
> I have a board with a ColdFire SoC on it with the built-in FEC
> ethernet module. On this hardware the FEC eth output is directly
> attached to a RTL8305 4-port 10/100 switch. There is no conventional
> PHY, the FEC output is direct into the uplink port of the switch
> chip.
> 
> This setup doesn't work after the FEC code was switch to using
> phylib. The driver used to have code to bypass phy detection/setup
> for this particular board. The phylib probe finds nothing, and of
> course sets a no-link condition.
> 
> So, what is the cleanest way to support this?
> 
> The attached patch adds a config option to do this sort of generically
> for the FEC driver. But I am wondering if there isn't a better way?
[...]

Perhaps there could be a null PHY driver which does no MDIO and always
reports link-up at the expected speed and duplex.  We used something
like that in the sfc driver for some PHY-less boards (though we use our
own PHY abstraction, not phylib).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

