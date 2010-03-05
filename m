From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Fix netdev_printk null dereference
Date: Fri, 05 Mar 2010 06:50:20 -0800
Message-ID: <1267800620.3832.17.camel@Joe-Laptop.home>
References: <1267793225-426-1-git-send-email-steve.glendinning@smsc.com>
	 <20100305.063909.26489418.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1429 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611Ab0CEOuV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Mar 2010 09:50:21 -0500
In-Reply-To: <20100305.063909.26489418.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-03-05 at 06:39 -0800, David Miller wrote:
> From: Steve Glendinning <steve.glendinning@smsc.com>
> Date: Fri,  5 Mar 2010 12:47:05 +0000
> 
> > This patch fixes a reproducible null dereference in smsc95xx (and I
> > suspect others) when the device is removed during a control register
> > access.  This can be reproduced by rapidly plugging and unplugging
> > the device during its initialisation.
> > 
> > Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> 
> The parent shouldn't become NULL until the device is totally quiesced
> and is no longer accesses.
> 
> Maybe you can instead fix the smsc95xx driver to abide by this rule
> instead of adding a conditional check to thousands of other drivers in
> the tree that do not need this?
> 
> I really have no intention of adding your change, please fix this
> properly, thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Perhaps something like this is appropriate in the mean time:

const char *get_netdev_parent_name(const struct net_device *dev)
{
	if (!dev->dev.parent)
		return "Unparented net_device, please report this";
	return netdev->dev.parent;
}


