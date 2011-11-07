From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] usbnet: fix oops in usbnet_start_xmit
Date: Mon, 07 Nov 2011 13:26:55 -0500 (EST)
Message-ID: <20111107.132655.1787743558315240070.davem@davemloft.net>
References: <20111106183337.5379.4356.stgit@zurg>
	<20111107145458.29997.79829.stgit@zurg>
	<20111107173919.GA2730@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khlebnikov@openvz.org, oneukum@suse.de, michael@riesch.at,
	alexey.orishko@gmail.com, netdev@vger.kernel.org, devel@openvz.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000Ab1KGS1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 13:27:07 -0500
In-Reply-To: <20111107173919.GA2730@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 7 Nov 2011 18:39:19 +0100

> On Mon, Nov 07, 2011 at 06:54:58PM +0300, Konstantin Khlebnikov wrote:
>> This patch fixes the bug added in commit v3.1-rc7-1055-gf9b491e
>> SKB can be NULL at this point, at least for cdc-ncm.
>> 
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> 
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Applied, but the overall logic in the usbnet transmit path definitely
could use a good reconsideration and cleanup.

I'm even open to having generic support at the generic net device TX
level to fixup the segmentation layout of the SKB so that it meets
the device's requirements.  We can do it more efficiently there too.
