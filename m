From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Validate ethtool autoneg before relaying
Date: Thu, 27 Nov 2008 00:07:48 -0800 (PST)
Message-ID: <20081127.000748.248098977.davem@davemloft.net>
References: <20081126221741.GA8800@xw6200.broadcom.net>
	<1227742092.13189.19.camel@HP1>
	<20081126234406.GA8970@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57896
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751939AbYK0IHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 03:07:48 -0500
In-Reply-To: <20081126234406.GA8970@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 26 Nov 2008 15:44:06 -0800

> On Wed, Nov 26, 2008 at 03:28:12PM -0800, Michael Chan wrote:
> > 
> > On Wed, 2008-11-26 at 14:17 -0800, Matt Carlson wrote:
> > > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > > index 14ada53..6362f56 100644
> > > --- a/net/core/ethtool.c
> > > +++ b/net/core/ethtool.c
> > > @@ -164,6 +164,9 @@ static int ethtool_set_settings(struct net_device *dev, void __user *useraddr)
> > >         if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
> > >                 return -EFAULT;
> > >  
> > > +       if (cmd.autoneg != AUTONEG_ENABLE && cmd.autoneg != AUTONEG_DISABLE)
> > > +               return -EFAULT;
> > > +
> > 
> > Matt, you should return -EINVAL here instead.
> 
> Yes.  You are right.  I'll fix this in a revised patch if everyone
> decides this is an effort worth pursuing.

I think this is a great idea, checking the validity in one spot.
So please, submit a final version of these changes when you get
a chance.
