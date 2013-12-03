From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH v2] macvlan: Support creating macvtaps from macvlans
Date: Tue, 3 Dec 2013 20:47:07 +0100
Message-ID: <20131203194707.GA32367@lion.mk-sys.cz>
References: <1386043991-4372-1-git-send-email-kevin@pentabarf.net>
 <1386068122-12039-1-git-send-email-kevin@pentabarf.net>
 <529E0421.2090504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kevin Wallace <kevin@pentabarf.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lion.mk-sys.cz ([213.168.178.121]:52159 "EHLO lion.mk-sys.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753620Ab3LCTrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Dec 2013 14:47:10 -0500
Content-Disposition: inline
In-Reply-To: <529E0421.2090504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 03, 2013 at 11:17:37AM -0500, Vlad Yasevich wrote:
> > diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> > index acf9379..cfb9157 100644
> > --- a/drivers/net/macvlan.c
> > +++ b/drivers/net/macvlan.c
> > @@ -820,13 +820,11 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
> >  	if (lowerdev == NULL)
> >  		return -ENODEV;
> >  
> > -	/* When creating macvlans on top of other macvlans - use
> > +	/* When creating macvlans or macvtaps on top of other macvlans - use
> >  	 * the real device as the lowerdev.
> >  	 */
> > -	if (lowerdev->rtnl_link_ops == dev->rtnl_link_ops) {
> > -		struct macvlan_dev *lowervlan = netdev_priv(lowerdev);
> > -		lowerdev = lowervlan->lowerdev;
> > -	}
> > +	if (netif_is_macvlan(lowerdev))
> > +		lowerdev = macvlan_dev_real_dev(lowerdev);
> >  
> >  	if (!tb[IFLA_MTU])
> >  		dev->mtu = lowerdev->mtu;
> > 
> 
> the other question is should this be done in a loop?  What happens if
> you have nested namespaces?

Nested namespaces are not a problem, what would be a problem, would be
having a macvlan (macvtap) device on top of another macvlan. But the
purpose of this particular code is to prevent it and use the underlying
"real" device instead. That's why unlike vlan_dev_real_dev(),
macvlan_dev_real_dev() doesn't need to recurse.

                                                         Michal Kubecek
