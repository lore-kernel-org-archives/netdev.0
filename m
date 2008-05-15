From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/3] net: handle errors from device_rename
Date: Thu, 15 May 2008 13:09:11 -0700
Message-ID: <20080515130911.6d38c09b@extreme>
References: <20080514170316.672f809d@extreme>
	<20080514181543.744b8286@extreme>
	<482BF744.6060106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
	fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:41713 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193AbYEOUJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 16:09:17 -0400
In-Reply-To: <482BF744.6060106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2008 16:41:40 +0800
Wang Chen <wangchen@cn.fujitsu.com> wrote:

> Stephen Hemminger said the following on 2008-5-15 9:15:
> >  rollback:
> > -	device_rename(&dev->dev, dev->name);
> > +	err = device_rename(&dev->dev, dev->name);
> > +	if (err) {
> > +		memcpy(dev->name, oldname, IFNAMSIZ);
>                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> no need, dev->name didn't change in device_rename().
>  
> > +		return err;
> > +	}
> >  

dev->name has already been changed before the call to device_rename,
so it needs to be set back read the whole code context.
