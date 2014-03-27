From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: include wait queue head in device structure
Date: Thu, 27 Mar 2014 14:59:48 -0400 (EDT)
Message-ID: <20140327.145948.29790647563036147.davem@davemloft.net>
References: <1395840771-1852-1-git-send-email-oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oneukum@suse.de
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56602 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755269AbaC0S7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 14:59:50 -0400
In-Reply-To: <1395840771-1852-1-git-send-email-oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: oliver@neukum.org
Date: Wed, 26 Mar 2014 14:32:51 +0100

> From: Oliver Neukum <oneukum@suse.de>
> 
> This fixes a race which happens by freeing an object on the stack.
> Quoting Julius:
>> The issue is
>> that it calls usbnet_terminate_urbs() before that, which temporarily
>> installs a waitqueue in dev->wait in order to be able to wait on the
>> tasklet to run and finish up some queues. The waiting itself looks
>> okay, but the access to 'dev->wait' is totally unprotected and can
>> race arbitrarily. I think in this case usbnet_bh() managed to succeed
>> it's dev->wait check just before usbnet_terminate_urbs() sets it back
>> to NULL. The latter then finishes and the waitqueue_t structure on its
>> stack gets overwritten by other functions halfway through the
>> wake_up() call in usbnet_bh().
> 
> The fix is to just not allocate the data structure on the stack.
> As dev->wait is abused as a flag it also takes a runtime PM change
> to fix this bug.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>
> Reported-by: Grant Grundler <grundler@google.com>
> Tested-by: Grant Grundler <grundler@google.com>

Applied and queued up for -stable, thanks Oliver.
