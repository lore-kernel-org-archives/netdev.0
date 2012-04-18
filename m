From: Ben Hutchings <bhutchings@solarflare.com>
Subject: re: net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Wed, 18 Apr 2012 15:13:14 +0100
Message-ID: <1334758394.3209.156.camel@deadeye>
References: <20120418064723.GA12831@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <Tristram.Ha@micrel.com>, <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46022 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751532Ab2DRONU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 10:13:20 -0400
In-Reply-To: <20120418064723.GA12831@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-18 at 09:47 +0300, Dan Carpenter wrote:
> Hello Tristram,
> 
> I was going through some old stuff and I had a question about ksz884x.c.
> 
> The patch 8ca86fd83eae: "net: Micrel KSZ8841/2 PCI Ethernet driver" 
> from Feb 8, 2010, leads to the following warning:
> drivers/net/ethernet/micrel/ksz884x.c:5678 netdev_set_mac_address()
> 	 error: memcpy() 'mac->sa_data' too small (14 vs 32)
> 
>   5663  static int netdev_set_mac_address(struct net_device *dev, void *addr)
>   5664  {
>   5665          struct dev_priv *priv = netdev_priv(dev);
>   5666          struct dev_info *hw_priv = priv->adapter;
>   5667          struct ksz_hw *hw = &hw_priv->hw;
>   5668          struct sockaddr *mac = addr;
>   5669          uint interrupt;
>   5670  
>   5671          if (priv->port.first_port > 0)
>   5672                  hw_del_addr(hw, dev->dev_addr);
>   5673          else {
>   5674                  hw->mac_override = 1;
>   5675                  memcpy(hw->override_addr, mac->sa_data, ETH_ALEN);
>   5676          }
>   5677  
>   5678          memcpy(dev->dev_addr, mac->sa_data, MAX_ADDR_LEN);
>                                       ^^^^^^^^^^^^
> This has only 14 bytes so we're copying bogus data from beyond the end
> of the struct into dev->dev_addr.

The correct length is ETH_ALEN, as for the previous memcpy().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
