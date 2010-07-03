From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 1/3] ethtool: Change ethtool_op_set_flags
 to validate flags
Date: Sat, 03 Jul 2010 20:21:24 +0100
Message-ID: <1278184884.4878.559.camel@localhost>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
	 <20100702095514.7fb324c8.randy.dunlap@oracle.com>
	 <20100702.220711.39188625.davem@davemloft.net>
	 <20100703120729.f2a2715b.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, sgruszka@redhat.com,
	amit.salecha@qlogic.com, amwang@redhat.com,
	anirban.chakraborty@qlogic.com, dm@chelsio.com, scofeldm@cisco.com,
	vkolluri@cisco.com, roprabhu@cisco.com,
	e1000-devel@lists.sourceforge.net, buytenh@wantstofly.org,
	gallatin@myri.com, brice@myri.com, shemminger@linux-foundation.org,
	jgarzik@redhat.com
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:45379 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755649Ab0GCTVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 15:21:32 -0400
In-Reply-To: <20100703120729.f2a2715b.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-07-03 at 12:07 -0700, Randy Dunlap wrote:
> On Fri, 02 Jul 2010 22:07:11 -0700 (PDT) David Miller wrote:
> 
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> > Date: Fri, 2 Jul 2010 09:55:14 -0700
> > 
> > > On Wed, 30 Jun 2010 13:44:32 +0100 Ben Hutchings wrote:
> > >> @@ -457,7 +457,7 @@ int ethtool_op_set_tso(struct net_device *dev, u32 data);
> > >>  u32 ethtool_op_get_ufo(struct net_device *dev);
> > >>  int ethtool_op_set_ufo(struct net_device *dev, u32 data);
> > >>  u32 ethtool_op_get_flags(struct net_device *dev);
> > >> -int ethtool_op_set_flags(struct net_device *dev, u32 data);
> > >> +int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported);
> > > 
> > > That one-line change is missing from linux-next-20100702, causing:
> > > 
> > > drivers/infiniband/ulp/ipoib/ipoib_ethtool.c:157: warning: initialization from incompatible pointer type
> > 
> > Strange, it's in net-next-2.6 for sure:
> > 
> > davem@sunset:~/src/GIT/net-next-2.6$ egrep ethtool_op_set_flags include/linux/ethtool.h
> > int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported);
> 
> Yep, my bad.
> 
> In include/linux/ethtool.h, struct ethtool_ops, field/member 'set_flags':
> 
> 	int	(*set_flags)(struct net_device *, u32);
> 
> Does that need another u32 for 'supported'?  This is where the linux-next
> warnings are coming from.

No, this is intentional.  I just missed the users of
ethtool_op_set_flags() in drivers/infiniband.  I'll send a patch for
those shortly.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

