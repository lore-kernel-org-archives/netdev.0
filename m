From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [net-next v2 70/71] tile: Move the Tilera driver
Date: Mon, 1 Aug 2011 13:21:54 -0400
Message-ID: <4E36E0B2.60900@tilera.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com> <1312082850-24914-71-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([206.83.70.75]:55064 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733Ab1HAR1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 13:27:01 -0400
In-Reply-To: <1312082850-24914-71-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/30/2011 11:27 PM, Jeff Kirsher wrote:
> Move the Tilera driver into drivers/net/ethernet/tile and
> make the necessary Kconfig and Makefile changes.
>
> CC: Chris Metcalf <cmetcalf@tilera.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> [...]
> +++ b/drivers/net/ethernet/tile/Kconfig
> @@ -0,0 +1,28 @@
> +#
> +# Tilera network device configuration
> +#
> +
> +config NET_VENDOR_TILERA
> +	bool "Tilera devices"
> +	depends on TILE
> +	---help---
> +	  If you have a network (Ethernet) card belonging to this class, say Y
> +	  and read the Ethernet-HOWTO, available from
> +	  <http://www.tldp.org/docs.html#howto>.
> +
> +	  Note that the answer to this question doesn't directly affect the
> +	  kernel: saying N will just cause the configurator to skip all
> +	  the questions about Tilera cards. If you say Y, you will be asked for
> +	  your specific card in the following questions.
> +
> +config TILE_NET
> +	tristate "Tilera GBE/XGBE network driver support"
> +	depends on NET_VENDOR_TILERA && TILE
> +	default y
> +	select CRC32
> +	---help---
> +	  This is a standard Linux network device driver for the
> +	  on-chip Tilera Gigabit Ethernet and XAUI interfaces.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called tile_net.

Overall, this seems fine, since the Tilera drivers get grouped more
appropriately as a result.  However, the drivers in question are not
Ethernet cards (and Tilera is not an Ethernet card vendor and has no plans
to become one).  Instead, this is the driver support for the built-in
networking hardware on the Tilera multicore CPU chip.  I'm happy to group
this support under drivers/net/ethernet/tile/, but I think it's appropriate
to default it to "Y" if you are building a TILE kernel (since you are
guaranteed to have the networking hardware available).

I suspect for now the cleanest thing to do is to fold the two config
options together, using NET_VENDOR_TILERA for consistency with other
NET_VENDOR_xxx symbols, and defaulting it to "Y" via "depends on TILE".  I
don't think the Ethernet-HOWO reference is particularly helpful since it
mostly tackles all the various card issues, kernel boot param issues, etc.,
none of which are relevant to this driver.  Something like:

+config NET_VENDOR_TILERA
+	bool "Tilera devices"
+	depends on TILE
+	default y
+	select CRC32
+	---help---
+	  This is a standard Linux network device driver for the arch/tile
+	  on-chip Gigabit Ethernet and XAUI interfaces.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called tile_net.


Obviously you'd also need to tweak the TILE_NET symbol in the Makefile to
be VENDOR_TILERA.  If this makes sense to you, go ahead and make the
change, and feel free to use my

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

