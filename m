From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,RESEND] phylib: fix premature freeing of struct mii_bus
Date: Tue, 18 Nov 2008 21:52:11 +0100
Message-ID: <20081118205211.GA15366@xi.wantstofly.org>
References: <20081118143307.GA12255@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bryan Wu <cooloney@kernel.org>, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:52211 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbYKRUwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 15:52:12 -0500
Content-Disposition: inline
In-Reply-To: <20081118143307.GA12255@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2008 at 03:33:07PM +0100, Lennert Buytenhek wrote:

> Commit 46abc02175b3c246dd5141d878f565a8725060c9 ("phylib: give mdio
> buses a device tree presence") added a call to device_unregister() in
> a situation where the caller did not intend for the device to be
> freed yet, but apart from just unregistering the device from the
> system, device_unregister() does an additional put_device() that is
> intended to free it.
> 
> The right function to use in this situation is device_del(), which
> unregisters the device from the system like device_unregister() does,
> but without dropping the reference count an additional time.
>     
> Bug report from Bryan Wu <cooloney@kernel.org>.

Sorry, ignore this, it seems that you already merged this on friday.
