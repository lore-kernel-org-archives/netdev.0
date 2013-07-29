From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] net/usb/r815x: replace USB buffer from stack to
 DMA-able
Date: Mon, 29 Jul 2013 00:46:02 -0700 (PDT)
Message-ID: <20130729.004602.803211032965671026.davem@davemloft.net>
References: <1374739144-732-1-git-send-email-hayeswang@realtek.com>
	<20130727.202107.555068116238400560.davem@davemloft.net>
	<1375075224.25230.1.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748Ab3G2HqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 03:46:03 -0400
In-Reply-To: <1375075224.25230.1.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Mon, 29 Jul 2013 07:20:24 +0200

> On Sat, 2013-07-27 at 20:21 -0700, David Miller wrote:
>> From: Hayes Wang <hayeswang@realtek.com>
>> Date: Thu, 25 Jul 2013 15:59:02 +0800
>> 
>> > Some USB buffers use stack which may not be DMA-able.
>> > Use the buffers from kmalloc to replace those one.
>> > 
>> > Signed-off-by: Hayes Wang <hayeswang@realtek.com>
>> 
>> I don't think it's reasonable to kmalloc() a small integer every time
>> you want to use a USB message transfer to read or write chip
>> registers.
>> 
>> Instead, add a scratch buffer to struct r8152 which is allocated once
>> at driver attach time and which you can use for the transfers.
>> 
>> I think you only need an array of two u32's so something like:
>> 
>> 	u32		transfer_buf[2];
>> 
>> ought to be sufficient.
> 
> We cannot do that. It would violate the rules about DMA coherency.
> We must not touch the same cacheline while DMA is in operation.

Good point, then it'll need to be:

	u32		*transfer_buf;

and allocated appropriately.
