From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] ipw2200: Fix NETDEV_TX_BUSY erroneous returned
Date: Thu, 5 Jan 2006 00:52:47 +0100
Message-ID: <20060104235247.GA8137@electric-eye.fr.zoreil.com>
References: <20060104040954.GA19618@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, jketreno@linux.intel.com,
	jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750791AbWADX45@vger.kernel.org>
To: Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
In-Reply-To: <20060104040954.GA19618@mail.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zhu Yi <yi.zhu@intel.com> :
> 
> This patch fixes the warning below warning for the ipw2200 driver.
> 
>   NETDEV_TX_BUSY returned; driver should report queue full via
>   ieee_device->is_queue_full.

Beyond what was said by Stephen Hemminger, the driver reports a
NETDEV_TX_BUSY when !STATUS_ASSOCIATED: neither this patch nor mine
fix it. 

Btw the patch that I posted earlier forgets to protect against 
every undue wake-up through:

ipw_rx
-> ipw_rx_notification
   -> priv->link_up (work_queue)
      -> ipw_bg_link_up
         -> ipw_link_up

It will need some extra care to correctly play the
netif_{stop/wake}_queue dance.

--
Ueimor
