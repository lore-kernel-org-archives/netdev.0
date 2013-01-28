From: David Miller <davem@davemloft.net>
Subject: Re: [patch] irda: buffer overflow in irnet_ctrl_read()
Date: Sun, 27 Jan 2013 20:39:00 -0500 (EST)
Message-ID: <20130127.203900.315969902013911354.davem@davemloft.net>
References: <20130125064056.GA4882@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756419Ab3A1BjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 20:39:02 -0500
In-Reply-To: <20130125064056.GA4882@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 25 Jan 2013 09:40:56 +0300

> The comments here say that the /* Max event is 61 char */ but in 2003 we
> changed the event format and now the max event size is 75.  The longest
> event is:
> 
> 	"Discovered %08x (%s) behind %08x {hints %02X-%02X}\n",
>          12345678901    23  456789012    34567890    1    2 3
> 	            +8    +21        +8          +2   +2     +1
>          = 75 characters.
> 
> There was a check to return -EOVERFLOW if the user gave us a "count"
> value that was less than 64.  Raising it to 75 might break backwards
> compatability.  Instead I removed the check and now it returns a
> truncated string if "count" is too low.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to net-next, thanks.
