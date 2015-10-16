From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: no addrconf for slave devices
Date: Fri, 16 Oct 2015 14:19:14 +0200
Message-ID: <1444997954.2885806.411975121.12F761E2@webmail.messagingengine.com>
References: <1444990911-27458-1-git-send-email-jblunck@infradead.org>
 <20151016115457.GE2194@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fubar@us.ibm.com
To: Jiri Pirko <jiri@resnulli.us>, Jan Blunck <jblunck@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151016115457.GE2194@nanopsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 16, 2015, at 13:54, Jiri Pirko wrote:
> Fri, Oct 16, 2015 at 12:21:51PM CEST, jblunck@infradead.org wrote:
> >If a device without the IFF_SLAVE flag set (e.g. team, bridge, openvswitch
> >vport, batman) is enslaved and IPv6 is active then addrconf will be
> >initiated and a link-local address is added to the slave interface.
> >
> >This patch alters the behavior so that addrconf will only run on the master
> >device itself. This is achieved by checking the device tree instead of
> >checking for a specific flag.
> >
> >Signed-off-by: Jan Blunck <jblunck@infradead.org>
> >---
> > net/ipv6/addrconf.c | 6 +++++-
> > 1 file changed, 5 insertions(+), 1 deletion(-)
> >
> >diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> >index 9001133..26d61f0 100644
> >--- a/net/ipv6/addrconf.c
> >+++ b/net/ipv6/addrconf.c
> >@@ -3141,8 +3141,12 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
> > 
> > 	case NETDEV_UP:
> > 	case NETDEV_CHANGE:
> >-		if (dev->flags & IFF_SLAVE)
> >+		/* If a master is set stop IPv6 on this interface */
> >+		if (netdev_master_upper_dev_get(dev)) {
> >+			if (idev)
> >+				addrconf_ifdown(dev, 1);
> 
> This breaks teamd if it's using NS/NA ping link-watch on link-local
> addresses.
> 
> What is the reason for this patch? Does it recolve any issue you are
> having?

I also feel uncomfortable with this change.

We can probably never change this behavior, ever. User space might
expect LL addresses on slave devices already. Same question as Jiri,
what was the motivation for this patch?

Bye,
Hannes
