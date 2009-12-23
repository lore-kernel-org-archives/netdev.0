From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v2 03/12] ixgbevf: Mailbox communication
Date: Wed, 23 Dec 2009 20:28:08 +0000
Message-ID: <1261600088.2782.72.camel@achroite.uk.solarflarecom.com>
References: <20091218225043.10698.58897.stgit@localhost.localdomain>
	 <20091218225140.10698.50205.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:20400 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbZLWU2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 15:28:12 -0500
In-Reply-To: <20091218225140.10698.50205.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-12-18 at 14:51 -0800, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The 82599 virtual function device and the master 82599 physical function
> device implement a mailbox utility for communication between the devices
> using some SRAM scratch memory and a doorbell/answering mechanism enabled
> via interrupt and/or polling.  This C module and accompanying header
> file implement the base functions for use of this feature.
[...]
> diff --git a/drivers/net/ixgbevf/mbx.c b/drivers/net/ixgbevf/mbx.c
> new file mode 100644
> index 0000000..a6e81fe
> --- /dev/null
> +++ b/drivers/net/ixgbevf/mbx.c
[...]
> +/**
> + *  ixgbevf_poll_for_msg - Wait for message notification
> + *  @hw: pointer to the HW structure
> + *
> + *  returns 0 if it successfully received a message notification
> + **/
> +static s32 ixgbevf_poll_for_msg(struct ixgbe_hw *hw)
> +{
> +	struct ixgbe_mbx_info *mbx = &hw->mbx;
> +	int countdown = mbx->timeout;
> +
> +	if (!mbx->ops.check_for_msg)
> +		goto out;
[...]

Can this ever be true?  Wouldn't that be a bug?

There are several similar, apparently unnecessary, tests in the
following functions.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

