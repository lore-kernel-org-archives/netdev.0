From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/4] atl1: Ancillary C files for Attansic L1 driver
Date: Thu, 11 Jan 2007 09:37:20 +0000
Message-ID: <20070111093720.GD3141@infradead.org>
References: <20070111004316.GE2624@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, shemminger@osdl.org, csnook@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:35697 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965351AbXAKJh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jan 2007 04:37:26 -0500
To: Jay Cliburn <jacliburn@bellsouth.net>
Content-Disposition: inline
In-Reply-To: <20070111004316.GE2624@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +#define ATL1_STATS_LEN sizeof(atl1_gstrings_stats) / sizeof(struct atl1_stats)

Just use an opencoded ARRAY_SIZE().

> +void atl1_read_pci_cfg(struct atl1_hw *hw, u32 reg, u16 * value)
> +{
> +        struct atl1_adapter *adapter = hw->back;
> +        pci_read_config_word(adapter->pdev, reg, value);
> +}
> +
> +void atl1_write_pci_cfg(struct atl1_hw *hw, u32 reg, u16 * value)
> +{
> +        struct atl1_adapter *adapter = hw->back;
> +        pci_write_config_word(adapter->pdev, reg, *value);
> +}

Please just kill these types of wrappers and use pci_read_config_word/
pci_write_config_word directly.

> +static inline bool atl1_eth_address_valid(u8 * p_addr)
> +{
> +	/* Invalid PermanentAddress ? */
> +	if (((p_addr[0] == 0) &&
> +	     (p_addr[1] == 0) &&
> +	     (p_addr[2] == 0) &&
> +	     (p_addr[3] == 0) && (p_addr[4] == 0) && (p_addr[5] == 0)
> +	    ) || (p_addr[0] & 1)) 
> +		/* Multicast address or Broadcast Address */
> +		return false;
> +
> +	return true;
> +}

Don't we have a generic helper for this kind of thing?

