From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] ethtool: Remove unimplemented flow
 specification types
Date: Wed, 15 Sep 2010 14:41:52 -0700 (PDT)
Message-ID: <20100915.144152.91337452.davem@davemloft.net>
References: <1284491403.2289.5.camel@achroite.uk.solarflarecom.com>
	<1284491588.2289.8.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	santwona.behera@sun.com, peter.p.waskiewicz.jr@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49690
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754286Ab0IOVld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 17:41:33 -0400
In-Reply-To: <1284491588.2289.8.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 14 Sep 2010 20:13:08 +0100

> struct ethtool_rawip4_spec and struct ethtool_ether_spec are neither
> commented nor used by any driver, so remove them.  Adjust padding in
> the user-visible unions that included these structures.
> 
> Fix references to struct ethtool_rawip4_spec in
> ethtool_get_rx_ntuple(), which should use struct ethtool_usrip4_spec.
> 
> struct ethtool_usrip4_spec cannot hold IPv6 host addresses and there
> is no separate structure that can, so remove ETH_RX_NFC_IP6 and the
> reference to it in niu.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Yeah.  The NIU chip's TCAM can only match on 32-bits (I think the
least significant) of the IPV6 address since that's how many bits
it has in the TCAM entries for addreses and address masks.

I'll apply this, thanks.
