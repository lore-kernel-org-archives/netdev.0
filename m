From: Alexander Aring <aar@pengutronix.de>
Subject: Re: [PATCH] ieee802154: check device type
Date: Sat, 23 Jul 2016 14:21:46 +0200
Message-ID: <6daeeb69-fc93-24b3-8218-bc483df65b45@pengutronix.de>
References: <1469004191-30920-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Alexander Aring <alex.aring@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Sergey Lapin <slapin@ossfans.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:38681 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751234AbcGWMVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2016 08:21:54 -0400
In-Reply-To: <1469004191-30920-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

On 07/20/2016 10:43 AM, Vegard Nossum wrote:
> I've observed a NULL pointer dereference in ieee802154_del_iface() during
> netlink fuzzing. It's the ->wpan_phy dereference here:
> 
>         phy = dev->ieee802154_ptr->wpan_phy;
> 
> My bet is that we're not checking that this is an IEEE802154 interface,
> so let's do what ieee802154_nl_get_dev() is doing. (Maybe we should even
> be calling this directly?)
> 
> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> Cc: Alexander Aring <alex.aring@gmail.com>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
> Cc: Sergey Lapin <slapin@ossfans.org>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

Acked-by: Alexander Aring <aar@pengutronix.de>

thanks for letting us known that this bug exists.

Unfortunate I don't care much about this code. This code is part of the
old UAPI for 802.15.4 subsystems and there are many bugs known.

Nevertheless I added my ack here and would like that Marcel apply this
patch into his bluetooth tree repository.

The new netlink api exists since 3.19 and highly recommended to don't
use the old stuff. The ieee802154 never got out the experimental state,
there was a patch [0] which globally remove the experimental Kconfig
entry, but no maintainer ever said that this branch isn't in
experimental state anymore.

I will prepare a RFC series to remove all deprecated handling which we
have replacements for it, these are:

 - old netlink api
 - af_802154 raw sockets, will replaced by AF_PACKET RAW

- Alex

[0] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/net/ieee802154/Kconfig?id=f4671a90c418b5aae14b61a9fc9d79c629403ca0
