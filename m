From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN 02/04]: Fix MAC address handling
Date: Wed, 11 Jul 2007 19:45:59 -0700 (PDT)
Message-ID: <20070711.194559.51844182.davem@davemloft.net>
References: <20070711173812.18369.47109.sendpatchset@localhost.localdomain>
	<20070711173815.18369.24201.sendpatchset@localhost.localdomain>
	<4695194A.3040908@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com, xemul@openvz.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34014
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758754AbXGLCpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 22:45:36 -0400
In-Reply-To: <4695194A.3040908@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 11 Jul 2007 19:54:18 +0200

> Patrick McHardy wrote:
> > [VLAN]: Fix MAC address handling
> > 
> > +static void vlan_sync_address(struct net_device *dev,
> > +			      struct net_device *vlandev)
> > +{
> > +	struct vlan_dev_info *vlan = VLAN_DEV_INFO(vlandev);
> > +
> > +	if (!compare_ether_addr(vlan->real_dev_addr, dev->dev_addr))
> > +		return;
> > +
> > +	if (compare_ether_addr(vlandev->dev_addr, dev->dev_addr))
> > +		dev_unicast_add(dev, vlandev->dev_addr, ETH_ALEN);
> > +	else
> > +		dev_unicast_delete(dev, vlandev->dev_addr, ETH_ALEN);
> > +
> > +	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
> > +}
> 
> 
> Unfortunately the one case I didn't test is still wrong :|
> 
> The above synchronization incorrectly removes the address in case
> if was different before and is still different afterwards. This
> patch is fixed and contains a few comments as an added bonus :)

So there is no confusion, I made sure to use this updated
version of the patch. :)
