From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 14/19] tulip: convert drivers to netdev_tx_t
Date: Tue, 1 Sep 2009 23:04:02 -0700
Message-ID: <20090901230402.22aa9d14@nehalam>
References: <20090901055039.824876937@vyatta.com>
	<20090901055129.814907029@vyatta.com>
	<20090902054801.GB28972@lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47581 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755735AbZIBGEI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 02:04:08 -0400
In-Reply-To: <20090902054801.GB28972@lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Sep 2009 23:48:01 -0600
Grant Grundler <grundler@parisc-linux.org> wrote:

> On Mon, Aug 31, 2009 at 10:50:53PM -0700, Stephen Hemminger wrote:
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > ---
> >  drivers/net/tulip/de2104x.c     |    3 ++-
> >  drivers/net/tulip/de4x5.c       |   11 +++++------
> >  drivers/net/tulip/dmfe.c        |    5 +++--
> >  drivers/net/tulip/tulip_core.c  |    5 +++--
> >  drivers/net/tulip/uli526x.c     |    6 ++++--
> >  drivers/net/tulip/winbond-840.c |    4 ++--
> >  drivers/net/tulip/xircom_cb.c   |    6 ++++--
> >  7 files changed, 23 insertions(+), 17 deletions(-)
> > 
> > --- a/drivers/net/tulip/de2104x.c	2009-08-29 23:10:19.609527457 -0700
> > +++ b/drivers/net/tulip/de2104x.c	2009-08-29 23:12:54.117527675 -0700
> > @@ -599,7 +599,8 @@ next:
> >  		netif_wake_queue(de->dev);
> >  }
> >  
> > -static int de_start_xmit (struct sk_buff *skb, struct net_device *dev)
> > +static netdev_tx_t de_start_xmit (struct sk_buff *skb,
> > +					struct net_device *dev)
> 
> Stephen,
> The patches look harmless and I'm inclined to ACK them...but google can't find
> any context or explanation for "netdev_tx_t". URL to email which proposed
> netdev_tx_t?
> 
> thanks,
> grant

>From patch series intro:

> This is a little change over a lot of files. It changes the
> return value of network device transmit from an integer to
> an enum type (like irqreturn_t).  This allows compiler to warn
> about stupid code that tries to return -ENOBUFS or other mistakes
> like that. All the code that did that is gone, but it would
> be better to try and do some decent type checking.
> 
> This patch converts all the x86 drivers (except staging).
> Other drivers will work but produce a warning until converted.
