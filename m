From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 11/11] ixgbe: allow eeprom writes via ethtool
Date: Fri, 30 Sep 2011 14:52:31 +0100
Message-ID: <1317390753.4068.32.camel@deadeye>
References: <1317360291-5576-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1317360291-5576-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Emil Tantilov <emil.s.tantilov@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:45565 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757981Ab1I3Nwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 09:52:43 -0400
In-Reply-To: <1317360291-5576-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-09-29 at 22:24 -0700, Jeff Kirsher wrote:
[...]
> +static int ixgbe_set_eeprom(struct net_device *netdev,
> +			    struct ethtool_eeprom *eeprom, u8 *bytes)
> +{
> +	struct ixgbe_adapter *adapter = netdev_priv(netdev);
> +	struct ixgbe_hw *hw = &adapter->hw;
> +	u16 *eeprom_buff;
> +	void *ptr;
> +	int max_len, first_word, last_word, ret_val = 0;
> +	u16 i;
> +
> +	if (eeprom->len == 0)
> +		return -EOPNOTSUPP;
> +
> +	if (eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
> +		return -EFAULT;
[...]

Both these error codes should be EINVAL.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
