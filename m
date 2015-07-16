From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 22/22] openvswitch: Use regular GRE net_device
 instead of vport
Date: Thu, 16 Jul 2015 16:52:46 +0200
Message-ID: <20150716145246.GC22603@pox.localdomain>
References: <cover.1436537414.git.tgraf@suug.ch>
 <74f200a9e634a9fefd6de85265f54b8a6697ab72.1436537414.git.tgraf@suug.ch>
 <20150716085915.GA11294@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	netdev@vger.kernel.org, dev@openvswitch.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:32934 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754714AbbGPOwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 10:52:49 -0400
Received: by widic2 with SMTP id ic2so17445498wid.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 07:52:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150716085915.GA11294@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/15 at 05:59pm, Simon Horman wrote:
> On Fri, Jul 10, 2015 at 04:19:24PM +0200, Thomas Graf wrote:
> >  static void ipgre_tap_setup(struct net_device *dev)
> >  {
> >  	ether_setup(dev);
> > -	dev->netdev_ops		= &gre_tap_netdev_ops;
> >  	dev->priv_flags 	|= IFF_LIVE_ADDR_CHANGE;
> >  	ip_tunnel_setup(dev, gre_tap_net_id);
> > +
> > +	if (!strcmp(dev->name, GRE_TAP_FB_NAME))
> > +		dev->netdev_ops		= &gre_fb_netdev_ops;
> > +	else
> > +		dev->netdev_ops		= &gre_tap_netdev_ops;
> >  }
> >  
> >  static int ipgre_newlink(struct net *src_net, struct net_device *dev,
> 
> [snip]
> 
> Is there a side-effect of the above that if a user creates a gretap device
> whose name is "gretap0" then the device will use gre_fb_netdev_ops instead
> of gre_tap_netdev_ops. If so, does that imply a change in behaviour for
> gretap devices created with that name?

I'm inclined to change this and use an in-kernel API as well to
create the net_device just like VXLAN does in patch 21.

Pravin, what do you think?
