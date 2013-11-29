From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/8] igb: Update queue reinit function to call dev_close
 when init of queues fails
Date: Fri, 29 Nov 2013 15:47:57 -0500 (EST)
Message-ID: <20131129.154757.2160926223289559260.davem@davemloft.net>
References: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1385624162-10116-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab3K2Ur7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 15:47:59 -0500
In-Reply-To: <1385624162-10116-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 27 Nov 2013 23:35:55 -0800

> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> This patch adds a call to dev_close if the queue reinit fails in order
> to make clearer to the user that the device is down.
> 
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

This is a very bad approach to this problem.

Users absolutely do not expect their entire interface to go down
simply because an ethtool request cannot be satisfied.  This is
extremely poor quality of implementation.

And in this specific case it absolutely is not necessary.

The only thing that can fail is the queue allocation, so make a
function which can preserve the previous configuration if the queue
allocation fails.  How about "igb_reinit_interrupt_scheme".

Don't free the q vectors until the very last moment, when you know
that the allocation of the new q vectors has succeeded.

I'm not applying this patch, it needs to be reimplemented more
sanely, using the above suggestions or similar.

Thanks.
