From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IGMP Unsolicited report interval patches
Date: Thu, 8 Aug 2013 11:01:05 +0200
Message-ID: <20130808090105.GA14001@order.stressinduktion.org>
References: <20130731063442.GA10498@order.stressinduktion.org> <1375812195-6575-1-git-send-email-william.manley@youview.com> <20130807010310.GH16410@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: William Manley <william.manley@youview.com>,
	netdev@vger.kernel.org, bcrl@kvack.org, luky-37@hotmail.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38834 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934040Ab3HHJBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 05:01:08 -0400
Content-Disposition: inline
In-Reply-To: <20130807010310.GH16410@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 07, 2013 at 03:03:10AM +0200, Hannes Frederic Sowa wrote:
> On Tue, Aug 06, 2013 at 07:03:12PM +0100, William Manley wrote:
> > 4th version of the patches.
> > 
> > The significant changes since last review are: 
> > 
> > 1. there is a new patch (2/3) as requested by Hannes.
> 
> Thanks!
> 
> > 2. the third patch now uses IN_DEV_CONF_GET in place of
> >    IPV4_DEVCONF_ALL.  This means that the unsolicited report interval can
> >    now be configured on an interface-by-interface basis as I'd originally
> >    intended but messed up in the implementation.  One concern I have now
> >    is that with this latest patch-set is that while
> >    /proc/sys/net/ipv4/conf/eth0/igmp... will now have an effect 
> >    /proc/sys/net/ipv4/conf/all/igmp... will not.  I'm not sure how to
> >    resolve this.
> 
> Hm, it seems to be come more difficult dealing with ranges.
> 
> One way would be, to check the state bit for the devinet entry and chose the
> all value always but when the state bit for the interface for this entry is
> set. I'll have a look on how to do this.

We copy ipv4_devconf_dftl over to the per-interface ipv4_devconf as long no
address is assigned to the interface.

The copy-over is guarded by by the cnf.state bitmap. It is set to all ones in
ipv4_devconf_setall which gets called at the relevant places. Instead of
setting all bits we could just apply a bitmask which would still allow a
propagation of the default/*igmp* parameters.

The all namespace has special semantics and decision what to apply are done
per knob. I wouldn't fiddle with that.

Greetings,

  Hannes
