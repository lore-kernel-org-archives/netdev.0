From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net 0/4] net: add rx_unhandled stat counter
Date: Thu, 28 Jan 2016 01:18:09 -0500
Message-ID: <20160128061808.GD59058@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <1453926098-40181-1-git-send-email-jarod@redhat.com>
 <1453928987.20722.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160128060215.GB59058@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57748 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932605AbcA1GSK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2016 01:18:10 -0500
Content-Disposition: inline
In-Reply-To: <20160128060215.GB59058@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2016 at 01:02:15AM -0500, Jarod Wilson wrote:
> On Wed, Jan 27, 2016 at 01:09:47PM -0800, Eric Dumazet wrote:
> > On Wed, 2016-01-27 at 15:21 -0500, Jarod Wilson wrote:
> > 
> > > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > > index 289c231..7973ab5 100644
> > > --- a/include/linux/netdevice.h
> > > +++ b/include/linux/netdevice.h
> > > @@ -180,6 +180,7 @@ struct net_device_stats {
> > >  	unsigned long	tx_window_errors;
> > >  	unsigned long	rx_compressed;
> > >  	unsigned long	tx_compressed;
> > > +	unsigned long	rx_unhandled;
> > >  };
> > >  
> > 
> > This structure is deprecated, please do not add new fields in it,
> > as it will increase netlink answers for no good reason.
> > 
> > rtnl_link_stats64 is what really matters these days.
> 
> I'll respin the set without that

Or not. Now I remember why I added that in the first place:

In file included from ./arch/x86/include/asm/uaccess.h:7:0,
                 from net/core/dev.c:75:
net/core/dev.c: In function 'netdev_stats_to_stats64':
include/linux/compiler.h:484:20: error: call to '__compiletime_assert_7263' declared with attribute error: BUILD_BUG_ON failed: sizeof(*stats64) != sizeof(*netdev_stats)
    prefix ## suffix();    \
                    ^

Things are actually hard-wired to require that addition at the moment, or
you get the above build failure. Not sure if it's safe to remove that
BUILD_BUG_ON() yet, haven't looked closely, it's past my bed time. :)

-- 
Jarod Wilson
jarod@redhat.com
