From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc3-mm2] 3c59x: support more ethtool_ops
Date: Tue, 5 Oct 2004 12:07:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005160719.GA21225@havoc.gtf.org>
References: <20041005134143.GA4829@gareth.mathematik.tu-chemnitz.de> <4162ACED.10303@pobox.com> <20041005160247.GA5405@gareth.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20041005160247.GA5405@gareth.mathematik.tu-chemnitz.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 05, 2004 at 06:02:47PM +0200, Steffen Klassert wrote:
> On Tue, Oct 05, 2004 at 10:17:17AM -0400 or thereabouts, Jeff Garzik wrote:
> > >+static u32 vortex_get_link(struct net_device *dev)
> > >+{
> > >+	struct vortex_private *vp = netdev_priv(dev);
> > >+	long ioaddr = dev->base_addr;
> > >+	EL3WINDOW(4);
> > >+	return mii_link_ok(&vp->mii);
> > >+}
> > 
> > 3c59x should properly use netif_carrier_{on,off}, at which point you can 
> > eliminate vortex_get_link in favor of generic ethtool_op_get_link
> 
> I tried to use ethtool_op_get_link, but then ethtool reports 
> Link detected: yes
> It does not matter wether the cable is connected or not.

Thus my comment "3c59x should properly use netif_carrier_{on,off}"  :)


> > >+static int vortex_set_settings(struct net_device *dev, struct ethtool_cmd 
> > >*cmd)
> > >+{
> > >+	struct vortex_private *vp = netdev_priv(dev);
> > >+	long ioaddr = dev->base_addr;
> > >+	EL3WINDOW(4);
> > >+	return mii_ethtool_sset(&vp->mii, cmd);
> > >+}
> > 
> > I think that this and the other MII patch should do some amount of 
> > locking, like the other drivers.
> 
> Unlike the other drivers, the 3c59x locks with spin_lock_bh inside 
> the mdio _{read,write} functions. Thats why I did not used any locks here.

Insufficient.  3c59x uses register windows, and you do not lock between
setting the window and using the window.

	Jeff
