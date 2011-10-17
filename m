From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 6/6] ixgbe: change the eeprom version reported by
 ethtool
Date: Mon, 17 Oct 2011 18:16:37 +0100
Message-ID: <1318871797.2784.36.camel@bwh-desktop>
References: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1318854062-3628-7-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1318867035.5407.5.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18763 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797Ab1JQRQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 13:16:43 -0400
In-Reply-To: <1318867035.5407.5.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-10-17 at 08:57 -0700, Joe Perches wrote:
> On Mon, 2011-10-17 at 05:21 -0700, Jeff Kirsher wrote:
> > From: Emil Tantilov <emil.s.tantilov@intel.com>
> > 
> > Use 32bit value starting at offset 0x2d for displaying the firmware
> > version in ethtool. This should work for all current ixgbe HW
> []
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> []
> > -	snprintf(firmware_version, sizeof(firmware_version), "%d.%d-%d",
> > -	         (adapter->eeprom_version & 0xF000) >> 12,
> > -	         (adapter->eeprom_version & 0x0FF0) >> 4,
> > -	         adapter->eeprom_version & 0x000F);
> > +	nvm_track_id = (adapter->eeprom_verh << 16) |
> > +			adapter->eeprom_verl;
> > +	snprintf(firmware_version, sizeof(firmware_version), "0x%08x",
> > +		 nvm_track_id);
> 
> Is ethtool output like proc output considered an abi
> that should not be changed?

No-one should make any assumptions about the format of firmware_version
strings.  However they ought to be consistent with vendor documentation,
update programs, etc.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
