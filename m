From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bna: don't disable VLAN tag stripping in promisc
 mode
Date: Thu, 27 Feb 2014 17:24:03 -0500 (EST)
Message-ID: <20140227.172403.1870812305847598692.davem@davemloft.net>
References: <1393525042-7791-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbaB0WYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:24:05 -0500
In-Reply-To: <1393525042-7791-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Thu, 27 Feb 2014 19:17:22 +0100

> The recent commit "fe1624c bna: RX Filter Enhancements" disables
> VLAN tag stripping if the NIC is in promiscuous mode. Received VLAN tagged
> packets are recognized by the driver via BNA_CQ_EF_VLAN flag and for such
> packets the driver calls __vlan_hwaccel_put_tag(). The problem is the HW
> marks the tagged packets with this flags also when the stripping is
> disabled and thus __vlan_hwaccel_put_tag() should not be called for them.
> 
> A solution can be to call __vlan_hwaccel_put_tag() only when stripping is
> enabled or to leave VLAN stripping engine enabled. The 2nd restores the
> previous behavior and is IMHO better.
> 
> Cc: Rasesh Mody <rmody@brocade.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

At best, this is an incomplete change, because if we fix it like this
then the stripping enable/disable functions are completely unused and
therefore should be removed from the driver.

But I really thing that checking if stripping is enabled at the
__vlan_hwaccel_put_tag() call site is the best solution.

You just need to check rxf->vlan_strip_status in addition to the
descriptor flag.

Please implement it this way, thanks.
