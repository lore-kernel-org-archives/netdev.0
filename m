From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b43: Increase number of RX DMA slots
Date: Tue, 19 Feb 2013 13:15:53 -0500 (EST)
Message-ID: <20130219.131553.787630407148880340.davem@davemloft.net>
References: <20130219.005206.397289032011003833.davem@davemloft.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7152@saturn3.aculab.com>
	<5123BCFF.5090408@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	bittorf@bluebottle.com, stable@vger.kernel.org
To: Larry.Finger@lwfinger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933300Ab3BSSPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 13:15:55 -0500
In-Reply-To: <5123BCFF.5090408@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Larry Finger <Larry.Finger@lwfinger.net>
Date: Tue, 19 Feb 2013 11:57:19 -0600

> The real problem is that some (perhaps all) versions of the firmware,
> which manages the 'in' pointer of the FIFO ring, appears to fail to
> detect the ring full condition. That is the real cause of the freeze;
> however, we do not have access to the firmware source. We don't even
> have the right to redistribute it, which is why we have the
> b43-fwcutter work around.

I understand your constraints, but this is a trivially remotely
DoS'able condition even on slow CPU atom laptops.

Send an "expansive" full sized frame followed by 300 or so 64-byte UDP
packets --> instant hang.
