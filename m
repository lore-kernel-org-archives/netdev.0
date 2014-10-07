From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: phy: adjust fixed_phy_register()
 return value
Date: Tue, 07 Oct 2014 00:07:54 -0400 (EDT)
Message-ID: <20141007.000754.1011567266866832634.davem@davemloft.net>
References: <20141006183830.D4E82100BC1@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	thomas.petazzoni@free-electrons.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbaJGEHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 00:07:55 -0400
In-Reply-To: <20141006183830.D4E82100BC1@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Mon,  6 Oct 2014 11:38:30 -0700 (PDT)

> Adjust fixed_phy_register() to return struct phy_device *, so that
> it becomes easy to use fixed PHYs without device tree support:
> 
>   phydev = fixed_phy_register(PHY_POLL, &fixed_phy_status, NULL);
>   fixed_phy_set_link_update(phydev, fixed_phy_link_update);
>   phy_connect_direct(netdev, phydev, handler_fn, phy_interface);
> 
> This change is a prerequisite for modifying bcmgenet driver to work
> without a device tree on Broadcom's MIPS-based 7xxx platforms.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

If the caller gets this 'phy' pointer and does something with it,
something seems amiss.

We don't hold an extra reference to the 'phy' object for the caller,
so another thread of control can unregister it and kill that last
reference and therefore free it up.

I think to be legitimate, you have to hold an extra reference on
'phy' for the caller.  And now that means that code paths that
don't need to do anything with 'phy' now will need to release
that reference.
