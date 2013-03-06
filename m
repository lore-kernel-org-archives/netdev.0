From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/4][pull request] Intel Wired LAN Driver Updates
Date: Tue, 05 Mar 2013 23:42:19 -0500 (EST)
Message-ID: <20130305.234219.1088734151840168640.davem@davemloft.net>
References: <1362476917-5189-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701Ab3CFEmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:42:21 -0500
In-Reply-To: <1362476917-5189-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  5 Mar 2013 01:48:33 -0800

> This series contains fixes to e1000e and igb.
> 
> The e1000e fix resolves an issue at 1000Mbps link speed, where one of the
> MAC's internal clocks can be stopped for up to 4us when entering K1 (a
> power mode of the MAC-PHY interconnect).  If the MAC is waiting for
> completion indications for 2 DMA write requests into Host memory
> (e.g. descriptor writeback or Rx packet writing) and the
> indications occur while the clock is stopped, both indications will be
> missed by the MAC causing the MAC to wait for the completion indications
> and be unable to generate further DMA write requests.  This results in an
> apparent hardware hang.  The patch works-around the issue by disabling
> the de-assertion of the clock request when 1000Mbps link is acquired (K1
> must be disabled while doing this).
> 
> The igb fix to drop BUILD_BUG_ON check from igb_build_rx_buffer resolves
> a build error on s390 devices.  The igb driver was throwing a build error
> due to the fact that a frame built using build_skb would be larger than 2K.
> Since this is not likely to change at any point in the future we are better
> off just dropping the check since we already had a check in
> igb_set_rx_buffer_len that will just disable the usage of build_skb anyway.
> 
> The igb fix for i210 link setup changes the setup copper link function
> to use a switch statement, so that the appropriate setup link function
> is called for the given PHY types.
> 
> Lastly, the igb fix for a lockdep issue in igb_get_i2c_client resolves
> the issue by re-factoring the initialization and usage of the i2c_client.

Pulled, thanks Jeff.
