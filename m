From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: fix automatic LRO/RSC settings for low
 latency
Date: Sun, 13 Jun 2010 18:21:10 -0700 (PDT)
Message-ID: <20100613.182110.112601110.davem@davemloft.net>
References: <20100611224629.30958.22500.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, andy@greyhouse.net,
	sgruszka@redhat.com, stable@kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753351Ab0FNBU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 21:20:59 -0400
In-Reply-To: <20100611224629.30958.22500.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 11 Jun 2010 15:47:03 -0700

> From: Andy Gospodarek <andy@greyhouse.net>
> 
> This patch added to 2.6.34:
> 
> 	commit f8d1dcaf88bddc7f282722ec1fdddbcb06a72f18
> 	Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 	Date:   Tue Apr 27 01:37:20 2010 +0000
> 
> 	    ixgbe: enable extremely low latency
> 
> introduced a feature where LRO (called RSC on the hardware) was disabled
> automatically when setting rx-usecs to 0 via ethtool.  Some might not
> like the fact that LRO was disabled automatically, but I'm fine with
> that.  What I don't like is that LRO/RSC is automatically enabled when
> rx-usecs is set >0 via ethtool.
> 
> This would certainly be a problem if the device was used for forwarding
> and it was determined that the low latency wasn't needed after the
> device was already forwarding.  I played around with saving the state of
> LRO in the driver, but it just didn't seem worthwhile and would require
> a small change to dev_disable_lro() that I did not like.
> 
> This patch simply leaves LRO disabled when setting rx-usecs >0 and
> requires that the user enable it again.  An extra informational message
> will also now appear in the log so users can understand why LRO isn't
> being enabled as they expect.
> 
> Inconsistency of LRO setting first noticed by Stanislaw Gruszka.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> CC: Stanislaw Gruszka <sgruszka@redhat.com>
> CC: stable@kernel.org
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
