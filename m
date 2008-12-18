From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH -next] netdevice zd1201: Use after free
Date: Thu, 18 Dec 2008 08:58:13 -0500
Message-ID: <20081218135813.GA4121@tuxdriver.com>
References: <20081031182207.GD4310@tuxdriver.com> <1225478896-28987-1-git-send-email-linville@tuxdriver.com> <4949F36B.7080707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36079 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbYLROAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 09:00:20 -0500
Content-Disposition: inline
In-Reply-To: <4949F36B.7080707@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 02:53:31PM +0800, Wang Chen wrote:
> | commit 3d29b0c33d431ecc69ec778f8c236d382f59a85f
> | Author: John W. Linville <linville@tuxdriver.com>
> | Date:   Fri Oct 31 14:13:12 2008 -0400
> | 
> |     netdevice zd1201: Convert directly reference of netdev->priv to netdev_priv()
> | 
> |     We have some reasons to kill netdev->priv:
> |     1. netdev->priv is equal to netdev_priv().
> |     2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
> |        netdev_priv() is more flexible than netdev->priv.
> |     But we cann't kill netdev->priv, because so many drivers reference to it
> |     directly.
> | 
> |     OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
> |     and I want to kill netdev->priv later, I decided to convert all the direct
> |     reference of netdev->priv first.
> | 
> |     (Original patch posted by Wang Chen <wangchen@cn.fujitsu.com> w/ above
> |     changelog but using dev->ml_priv.  That doesn't seem appropriate
> |     to me for this driver, so I've revamped it to use netdev_priv()
> |     instead. -- JWL)
> 
> This commit changed the allocation of netdev, but didn't change
> the free method of it.
> This causes "zd" be used after the memory, which is pointed by "zd", being
> freed by free_netdev().

Oops...thanks!

John
-- 
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
