From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: network device name ifalias support
Date: Mon, 22 Sep 2008 20:47:18 -0700
Message-ID: <20080922204718.2782b5b6@extreme>
References: <20080922174346.2ad15d26@extreme>
	<20080922.194423.116365505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51669 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154AbYIWDrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 23:47:23 -0400
In-Reply-To: <20080922.194423.116365505.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Sep 2008 19:44:23 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 22 Sep 2008 17:43:46 -0700
> 
> > +	dev->ifalias = krealloc(dev->ifalias, len+1, GFP_KERNEL);
> > +	if (!dev->ifalias)
> > +		return -ENOMEM;
> > +
> > +	strlcpy(dev->ifalias, alias, len+1);
> > +	return len;
> 
> It might be cleaner to use kstrdup() and free the old pointer, if
> any, here.
> 
> 	char *new = kstrdup(alias, GFP_KERNEL);
> 	if (!new)
> 		return -ENOMEM;
> 	kfree(dev->ifalias);
> 	dev->ifalias = new;
> 	return len;
> 
> That way all of this "len+1" stuff goes away.

Won't work because input string is not necessarily null-terminated.
In the sysfs case we want there is a trailing newline, and this
way avoids copying once there and then copying again.
