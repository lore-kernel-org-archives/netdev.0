From: David Miller <davem@davemloft.net>
Subject: Re: [patch] USB: kaweth.c: use GFP_ATOMIC under spin_lock
Date: Fri, 27 Jul 2012 13:46:32 -0700 (PDT)
Message-ID: <20120727.134632.76746326614521026.davem@davemloft.net>
References: <20120727114651.GA15492@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329Ab2G0Uqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 16:46:33 -0400
In-Reply-To: <20120727114651.GA15492@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 27 Jul 2012 14:46:51 +0300

> The problem is that we call this with a spin lock held.  The call tree
> is:
> 	kaweth_start_xmit() holds kaweth->device_lock.
> 	-> kaweth_async_set_rx_mode()
> 	   -> kaweth_control()
> 	      -> kaweth_internal_control_msg()
> 
> The kaweth_internal_control_msg() function is only called from
> kaweth_control() which used GFP_ATOMIC for its allocations.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
