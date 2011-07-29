From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next-2.6] dummy: allow report link status and change
 it via sysfs
Date: Fri, 29 Jul 2011 09:55:23 -0700
Message-ID: <20110729095523.24f8d2dc@nehalam.ftrdhcpuser.net>
References: <1311953253-25059-1-git-send-email-jpirko@redhat.com>
	<1311955389.3220.15.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, eric.dumazet@gmail.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58779 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458Ab1G2QzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2011 12:55:13 -0400
In-Reply-To: <1311955389.3220.15.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Jul 2011 18:03:09 +0200
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Fri, 2011-07-29 at 17:27 +0200, Jiri Pirko wrote:
> > Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> > ---
> >  drivers/net/dummy.c |   54 +++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 54 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
> > index 39cf9b9..fc39c24 100644
> > --- a/drivers/net/dummy.c
> > +++ b/drivers/net/dummy.c
> > @@ -37,9 +37,57 @@
> >  #include <linux/rtnetlink.h>
> >  #include <net/rtnetlink.h>
> >  #include <linux/u64_stats_sync.h>
> > +#include <linux/ethtool.h>
> >  
> >  static int numdummies = 1;
> >  
> > +static ssize_t dummy_show_link(struct device *d,
> > +			       struct device_attribute *attr,
> > +			       char *buf)
> > +{
> > +	struct net_device *dev = to_net_dev(d);
> > +
> > +	return sprintf(buf, "%d\n", netif_carrier_ok(dev) ? 1 : 0);
> > +}
> [...]
> 
> Net devices already have the 'carrier' attribute.  You should make that
> attribute writable for dummy devices, rather than adding another one.
> 

And adding ethtool support is unnecessary since carrier is already
reported by tools like 'ip link'
