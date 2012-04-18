From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Wed, 18 Apr 2012 09:47:23 +0300
Message-ID: <20120418064723.GA12831@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tristram.Ha@micrel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:49722 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab2DRGrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 02:47:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Tristram,

I was going through some old stuff and I had a question about ksz884x.c.

The patch 8ca86fd83eae: "net: Micrel KSZ8841/2 PCI Ethernet driver" 
from Feb 8, 2010, leads to the following warning:
drivers/net/ethernet/micrel/ksz884x.c:5678 netdev_set_mac_address()
	 error: memcpy() 'mac->sa_data' too small (14 vs 32)

  5663  static int netdev_set_mac_address(struct net_device *dev, void *addr)
  5664  {
  5665          struct dev_priv *priv = netdev_priv(dev);
  5666          struct dev_info *hw_priv = priv->adapter;
  5667          struct ksz_hw *hw = &hw_priv->hw;
  5668          struct sockaddr *mac = addr;
  5669          uint interrupt;
  5670  
  5671          if (priv->port.first_port > 0)
  5672                  hw_del_addr(hw, dev->dev_addr);
  5673          else {
  5674                  hw->mac_override = 1;
  5675                  memcpy(hw->override_addr, mac->sa_data, ETH_ALEN);
  5676          }
  5677  
  5678          memcpy(dev->dev_addr, mac->sa_data, MAX_ADDR_LEN);
                                      ^^^^^^^^^^^^
This has only 14 bytes so we're copying bogus data from beyond the end
of the struct into dev->dev_addr.

  5679  

regards,
dan carpenter
