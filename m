From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 6/6] ixgbe: change the eeprom version reported by
 ethtool
Date: Mon, 17 Oct 2011 08:57:15 -0700
Message-ID: <1318867035.5407.5.camel@Joe-Laptop>
References: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1318854062-3628-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Emil Tantilov <emil.s.tantilov@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59064 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756371Ab1JQP5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 11:57:16 -0400
In-Reply-To: <1318854062-3628-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-10-17 at 05:21 -0700, Jeff Kirsher wrote:
> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Use 32bit value starting at offset 0x2d for displaying the firmware
> version in ethtool. This should work for all current ixgbe HW
[]
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
[]
> -	snprintf(firmware_version, sizeof(firmware_version), "%d.%d-%d",
> -	         (adapter->eeprom_version & 0xF000) >> 12,
> -	         (adapter->eeprom_version & 0x0FF0) >> 4,
> -	         adapter->eeprom_version & 0x000F);
> +	nvm_track_id = (adapter->eeprom_verh << 16) |
> +			adapter->eeprom_verl;
> +	snprintf(firmware_version, sizeof(firmware_version), "0x%08x",
> +		 nvm_track_id);

Is ethtool output like proc output considered an abi
that should not be changed?
