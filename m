From: David Hollis <dhollis@davehollis.com>
Subject: Re: [PATCH] asix: Add support for AX88772A devices
Date: Mon, 12 Jan 2009 20:06:15 -0500
Message-ID: <1231808775.591.6.camel@dhollis-lnx>
References: <1231602265.9020.17.camel@dhollis-lnx>
	<20090111.001704.107600670.davem@davemloft.net>
	<20090112.161850.235337113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173001pub.verizon.net ([206.46.173.1]:42184 "EHLO
	vms173001pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755059AbZAMBGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 20:06:48 -0500
Received: from smtp.davehollis.com ([96.243.190.12]) by vms173001.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0KDD003IAXQKWYJ6@vms173001.mailsrvcs.net> for
 netdev@vger.kernel.org; Mon, 12 Jan 2009 19:06:20 -0600 (CST)
In-reply-to: <20090112.161850.235337113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-01-12 at 16:18 -0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 11 Jan 2009 00:17:04 -0800 (PST)
> 
> > From: David Hollis <dhollis@davehollis.com>
> > Date: Sat, 10 Jan 2009 10:44:25 -0500
> > 
> > > @@ -878,20 +885,22 @@ static struct ethtool_ops ax88772_ethtoo
> > >  
> > >  static int ax88772_link_reset(struct usbnet *dev)
> > >  {
> > > -	u16 mode;
> > > -	struct ethtool_cmd ecmd;
> > > +	u16 mode = AX88772_MEDIUM_DEFAULT;
> > > +	u16 bmcr;
> > >  
> > > -	mii_check_media(&dev->mii, 1, 1);
> > > -	mii_ethtool_gset(&dev->mii, &ecmd);
> > > -	mode = AX88772_MEDIUM_DEFAULT;
> > > +	bmcr = asix_mdio_read(dev->net, dev->mii.phy_id, MII_BMCR);
> > 
> > Just out of curiosity, why did you have to change this
> > function to not use the generic mii_*() routines just
> > to support this new device variant?
> 
> Ping?
> 
> I'm not applying this patch until you answer this question.
> 

I'm currently waiting on feedback from the original contributor of the
patch.  I looked through the mii_ethtool_gset function and it
effectively is performing the same task (and then some) so I can't see
any reason why the link_reset() function needs the changes.  I'll submit
a new patch without those changes and will submit any changes to the
link_reset() that may happen to be required when I get a response from
the contributor.

Thanks.


> Thank you.

