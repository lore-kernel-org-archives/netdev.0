From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Tue, 20 Jul 2010 12:20:44 +0100
Message-ID: <1279624844.2110.3.camel@achroite.uk.solarflarecom.com>
References: <4C457F72.8090708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, Andy Gospodarek <gospo@redhat.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Casey Leedom <leedom@chelsio.com>,
	Harald Hoyer <harald@redhat.com>
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:32697 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932167Ab0GTLUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 07:20:48 -0400
In-Reply-To: <4C457F72.8090708@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-07-20 at 12:50 +0200, Stefan Assmann wrote:
> From: Stefan Assmann <sassmann@redhat.com>
> 
> Reserve a bit in struct net_device to indicate whether an interface
> generates its MAC address randomly, and expose the information via
> sysfs.
> May look like this:
> /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/net/eth0/ifrndmac
> 
> By default the value of ifrndmac is 0. Any driver that generates the MAC
> address randomly should return a value to 1.

The name should incorporate 'address', not 'mac', for consistency with
the generic 'address' attribute.

What about devices that 'steal' MAC addresses from slave devices?
Currently I believe udev has special cases for them but ideally these
drivers would indicate explicitly that their addresses are not stable
identifiers (even though they aren't random).

[...]
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index b626289..2ea0298 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -845,6 +845,7 @@ struct net_device {
>  #define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
>  #define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
>  #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
> +#define NETIF_F_RNDMAC		(1 << 29) /* Interface with random MAC address */
[...]

This is not really a feature, and we are running out of real feature
bits.  Can you find somewhere else to put this flag?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

