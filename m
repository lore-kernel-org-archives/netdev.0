From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 11/12] e1000e: Fix/cleanup PHY reset code
 for ICHx/PCHx
Date: Wed, 12 May 2010 23:32:38 -0700 (PDT)
Message-ID: <20100512.233238.102544818.davem@davemloft.net>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
	<20100511010230.30827.69868.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754187Ab0EMGca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 02:32:30 -0400
In-Reply-To: <20100511010230.30827.69868.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 10 May 2010 18:02:32 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> i) Fixes a bug where e1000_sw_lcd_config_ich8lan() was calling
> e1000_lan_init_done_ich8lan() to poll the STATUS.LAN_INIT_DONE bit to
> make sure the MAC had completed the PHY configuration.  However,
> e1000_lan_init_done_ich8lan() had already been called in one of the two
> places where PHY reset occurs for ICHx/PCHx parts, which caused the second
> call to busy-wait for 150 msec because the LAN_INIT_DONE bit had already
> been checked and cleared.
> 
> ii) Cleanup the two separate PHY reset code paths, i.e. the full-chip reset
> in e1000_reset_hw_ich8lan() and the PHY-only reset in
> e1000_phy_hw_reset_ich8lan().  There was duplicate code in both paths to be
> performed post-reset that are now combined into one new function -
> e1000_post_phy_reset_ich8lan().  This cleanup also included moving the
> clearing of the PHY Reset Asserted bit in the STATUS register (now done for
> all ICH/PCH parts) and the check for the indication from h/w that basic
> configuration has completed back to where it previously was in
> e1000_get_cfg_done_ich8lan().
> 
> iii) Corrected a few comments
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
