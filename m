From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: Add DEVTYPE support for Ethernet based devices
Date: Tue, 01 Sep 2009 00:33:09 -0700
Message-ID: <1251790389.1266.42.camel@localhost.localdomain>
References: <1251788899-30156-1-git-send-email-marcel@holtmann.org>
	 <1251789924.5327.4.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:56426 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbZIAHd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 03:33:59 -0400
In-Reply-To: <1251789924.5327.4.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

> > The new SET_NETDEV_DEVTYPE() is a convenience helper to set the actual
> > device type. All device types are free form, but for convenience the
> > same strings as used with RFKILL are choosen.
> 
> > --- a/net/mac80211/iface.c
> > +++ b/net/mac80211/iface.c
> > @@ -754,6 +754,10 @@ int ieee80211_if_change_type(struct ieee80211_sub_if_data *sdata,
> >  	return 0;
> >  }
> >  
> > +static struct device_type wiphy_type = {
> > +	.name	= "wlan",
> > +};
> > +
> >  int ieee80211_if_add(struct ieee80211_local *local, const char *name,
> >  		     struct net_device **new_dev, enum nl80211_iftype type,
> >  		     struct vif_params *params)
> > @@ -785,6 +789,7 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
> >  
> >  	memcpy(ndev->dev_addr, local->hw.wiphy->perm_addr, ETH_ALEN);
> >  	SET_NETDEV_DEV(ndev, wiphy_dev(local->hw.wiphy));
> > +	SET_NETDEV_DEVTYPE(ndev, &wiphy_type);
> 
> Can't you move that into the NETDEV_REGISTER hook in cfg80211? That way
> orinoco, rndis and iwm don't need updating now.

I am not sure if that would work, but it is worth testing it. If it
works, I clearly would prefer this.

Regards

Marcel


