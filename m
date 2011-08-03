From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [net-next v2 70/71] tile: Move the Tilera driver
Date: Wed, 3 Aug 2011 15:02:20 -0400
Message-ID: <4E399B3C.4010902@tilera.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>  <1312082850-24914-71-git-send-email-jeffrey.t.kirsher@intel.com>  <4E36E0B2.60900@tilera.com> <1312350454.2294.86.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([206.83.70.75]:11518 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872Ab1HCTCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 15:02:22 -0400
In-Reply-To: <1312350454.2294.86.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/3/2011 1:47 AM, Jeff Kirsher wrote:
> On 7/30/2011 11:27 PM, Jeff Kirsher wrote:
>>> Move the Tilera driver into drivers/net/ethernet/tile and
>>> make the necessary Kconfig and Makefile changes.
>>>
>>> CC: Chris Metcalf <cmetcalf@tilera.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> [...]
>>> +++ b/drivers/net/ethernet/tile/Kconfig
>>> @@ -0,0 +1,28 @@
>>> +#
>>> +# Tilera network device configuration
>>> +#
>>> +
>>> +config NET_VENDOR_TILERA
>>> +	bool "Tilera devices"
>>> +	depends on TILE
>>> +	---help---
>>> +	  If you have a network (Ethernet) card belonging to this class, say Y
>>> +	  and read the Ethernet-HOWTO, available from
>>> +	  <http://www.tldp.org/docs.html#howto>.
>>> +
>>> +	  Note that the answer to this question doesn't directly affect the
>>> +	  kernel: saying N will just cause the configurator to skip all
>>> +	  the questions about Tilera cards. If you say Y, you will be asked for
>>> +	  your specific card in the following questions.
>>> +
>>> +config TILE_NET
>>> +	tristate "Tilera GBE/XGBE network driver support"
>>> +	depends on NET_VENDOR_TILERA && TILE
>>> +	default y
>>> +	select CRC32
>>> +	---help---
>>> +	  This is a standard Linux network device driver for the
>>> +	  on-chip Tilera Gigabit Ethernet and XAUI interfaces.
>>> +
>>> +	  To compile this driver as a module, choose M here: the module
>>> +	  will be called tile_net.
>>>
> [...]
>
> This Kconfig would automatically default to y for TILE kernels and would
> allow you to easily add additional future drivers for Tilera silicon,
> and if you expand to other architectures/systems in the future it would
> also allow for that as well.  Your thoughts?
>
> Otherwise I can have it just as this:
> +config TILE_NET
> +       tristate "Tilera GBE/XGBE network driver support"
> +       depends on TILE
> +       default y
> +       select CRC32
> +       ---help---
> +         This is a standard Linux network device driver for the
> +         on-chip Tilera Gigabit Ethernet and XAUI interfaces.
> +
> +         To compile this driver as a module, choose M here: the module
> +         will be called tile_net.
>
> Because you only have 1 driver, there is no large need to add the
> NET_VENDOR_<blah> and it can always be added in the future if the need
> arises.

Honestly, I think I'd prefer the simple TILE_NET solution.  My sense is
that even for the next generation of the chip, we're likely to keep using
TILE_NET to enable it in the config.  Note that we have done this now for
both tilepro and tilegx, though we haven't pushed the tilegx driver back to
the community yet; look at the conditionals in drivers/net/tile/Makefile to
see what I mean.  So let's stick with the simple thing for now.  Thanks!

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

