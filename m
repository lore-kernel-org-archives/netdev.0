From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: network device name ifalias support
Date: Mon, 22 Sep 2008 21:28:34 -0700 (PDT)
Message-ID: <20080922.212834.184909406.davem@davemloft.net>
References: <20080922174346.2ad15d26@extreme>
	<20080922.194423.116365505.davem@davemloft.net>
	<20080922204718.2782b5b6@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36553
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750829AbYIWE2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 00:28:46 -0400
In-Reply-To: <20080922204718.2782b5b6@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 22 Sep 2008 20:47:18 -0700

> On Mon, 22 Sep 2008 19:44:23 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > It might be cleaner to use kstrdup() and free the old pointer, if
> > any, here.
> > 
> > 	char *new = kstrdup(alias, GFP_KERNEL);
> > 	if (!new)
> > 		return -ENOMEM;
> > 	kfree(dev->ifalias);
> > 	dev->ifalias = new;
> > 	return len;
> > 
> > That way all of this "len+1" stuff goes away.
> 
> Won't work because input string is not necessarily null-terminated.
> In the sysfs case we want there is a trailing newline, and this
> way avoids copying once there and then copying again.

Ok, fair enough.  I've applied your original patch to net-next-2.6,
thanks!
