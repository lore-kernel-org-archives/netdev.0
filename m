From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next 5/6] net: use core MTU range checking in virt
 drivers
Date: Wed, 19 Oct 2016 10:17:58 -0400
Message-ID: <20161019141758.GC18569@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161019023333.15760-6-jarod@redhat.com>
 <20161019165629-mutt-send-email-mst@kernel.org>
 <20161019170330-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Shrikrishna Khare <skhare@vmware.com>,
        "VMware, Inc." <pv-drivers@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161019170330-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 19, 2016 at 05:03:43PM +0300, Michael S. Tsirkin wrote:
> On Wed, Oct 19, 2016 at 04:59:46PM +0300, Michael S. Tsirkin wrote:
> > On Tue, Oct 18, 2016 at 10:33:32PM -0400, Jarod Wilson wrote:
> > > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > > index fad84f3..4885a42 100644
> > > --- a/drivers/net/virtio_net.c
> > > +++ b/drivers/net/virtio_net.c
> > > @@ -1419,17 +1419,6 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
> > >  	.set_settings = virtnet_set_settings,
> > >  };
> > >  
> > > -#define MIN_MTU 68
> > > -#define MAX_MTU 65535
> > > -
> > > -static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
> > > -{
> > > -	if (new_mtu < MIN_MTU || new_mtu > MAX_MTU)
> > > -		return -EINVAL;
> > > -	dev->mtu = new_mtu;
> > > -	return 0;
> > > -}
> > > -
> > >  static const struct net_device_ops virtnet_netdev = {
> > >  	.ndo_open            = virtnet_open,
> > >  	.ndo_stop   	     = virtnet_close,
> > > @@ -1437,7 +1426,6 @@ static const struct net_device_ops virtnet_netdev = {
> > >  	.ndo_validate_addr   = eth_validate_addr,
> > >  	.ndo_set_mac_address = virtnet_set_mac_address,
> > >  	.ndo_set_rx_mode     = virtnet_set_rx_mode,
> > > -	.ndo_change_mtu	     = virtnet_change_mtu,
> > >  	.ndo_get_stats64     = virtnet_stats,
> > >  	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
> > >  	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
> > > @@ -1748,6 +1736,9 @@ static bool virtnet_validate_features(struct virtio_device *vdev)
> > >  	return true;
> > >  }
> > >  
> > > +#define MIN_MTU ETH_MIN_MTU
> > > +#define MAX_MTU 65535
> > > +
> > 
> > Do we need a common macro for this?
> 
> I think it's actually IP_MAX_MTU.

Ah, yes, it is. I'm not sure why I didn't use that...

-- 
Jarod Wilson
jarod@redhat.com
