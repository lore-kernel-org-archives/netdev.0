From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] phylib: fix premature freeing of struct mii_bus
Date: Sun, 9 Nov 2008 02:59:50 +0100
Message-ID: <20081109015950.GX32552@xi.wantstofly.org>
References: <20081107210617.GS32552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeff@garzik.org, Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:60496 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753575AbYKIB7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 20:59:53 -0500
Content-Disposition: inline
In-Reply-To: <20081107210617.GS32552@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 07, 2008 at 10:06:17PM +0100, Lennert Buytenhek wrote:

> From: Lennert Buytenhek <buytenh@wantstofly.org>
> 
> Commit 46abc02175b3c246dd5141d878f565a8725060c9 ("phylib: give mdio
> buses a device tree presence") added a call to device_unregister() in
> a situation where the caller did not expect the reference count on
> the embedded kobject to be dropped, but device_unregister() does drop
> that reference count.  The right function to use in this situation
> is device_del(), which unregisters the device from the system like
> device_unregister() does, but without dropping the reference count.

Wait a minute -- the original code _is_ correct.  mdiobus_register()
bumps the refcount to two (once because of device_initialize(), once
because of device_add()), mdiobus_unregister() drops it back to one,
and mdiobus_free() drops it to zero.

Trying to figure out what's going on... please don't apply this for now.
