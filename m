From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 02/11] ixgbe: fix flags relating to perfect filters
 to support coexistence
Date: Thu, 23 Jun 2011 23:40:41 -0700
Message-ID: <1308897641.11000.11.camel@Joe-Laptop>
References: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1308895397-23133-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3196 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751852Ab1FXGkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 02:40:43 -0400
In-Reply-To: <1308895397-23133-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-23 at 23:03 -0700, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
[]
> @@ -114,11 +114,12 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
>  	u8 err = 0;
>  	struct ixgbe_adapter *adapter = netdev_priv(netdev);
>  
> +	/* verify there is something to do, if not then exit */
> +	if (!!state != !(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
> +		return err;

That's a bit hard to read.  Maybe this is clearer?

	if (!!state == !!(adapter->flags & IXGBE_FLAG_DCG_ENABLED))


