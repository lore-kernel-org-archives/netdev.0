From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [PATCH 2.6.9-rc3-mm2] 3c59x: support more ethtool_ops
Date: Tue, 5 Oct 2004 18:02:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005160247.GA5405@gareth.mathematik.tu-chemnitz.de>
References: <20041005134143.GA4829@gareth.mathematik.tu-chemnitz.de> <4162ACED.10303@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4162ACED.10303@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 05, 2004 at 10:17:17AM -0400 or thereabouts, Jeff Garzik wrote:
> >+static u32 vortex_get_link(struct net_device *dev)
> >+{
> >+	struct vortex_private *vp = netdev_priv(dev);
> >+	long ioaddr = dev->base_addr;
> >+	EL3WINDOW(4);
> >+	return mii_link_ok(&vp->mii);
> >+}
> 
> 3c59x should properly use netif_carrier_{on,off}, at which point you can 
> eliminate vortex_get_link in favor of generic ethtool_op_get_link

I tried to use ethtool_op_get_link, but then ethtool reports 
Link detected: yes
It does not matter wether the cable is connected or not.

> >+
> >+static int vortex_set_settings(struct net_device *dev, struct ethtool_cmd 
> >*cmd)
> >+{
> >+	struct vortex_private *vp = netdev_priv(dev);
> >+	long ioaddr = dev->base_addr;
> >+	EL3WINDOW(4);
> >+	return mii_ethtool_sset(&vp->mii, cmd);
> >+}
> 
> I think that this and the other MII patch should do some amount of 
> locking, like the other drivers.

Unlike the other drivers, the 3c59x locks with spin_lock_bh inside 
the mdio _{read,write} functions. Thats why I did not used any locks here.

Steffen
