From: Koichiro Den <den@klaipeden.com>
Subject: Re: [PATCH net-next] virtio-net: make napi_tx param easier to grasp
Date: Mon, 21 Aug 2017 20:49:10 +0900
Message-ID: <1503316150.8694.1.camel@klaipeden.com>
References: <20170819063707.26822-1-den@klaipeden.com>
         <CAF=yD-JA_JPyUbDd=SR9Epvzw6-kbUcrfvwRWODwmeV+yHEMHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21423 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750967AbdHULtS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 07:49:18 -0400
In-Reply-To: <CAF=yD-JA_JPyUbDd=SR9Epvzw6-kbUcrfvwRWODwmeV+yHEMHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-08-20 at 16:30 -0400, Willem de Bruijn wrote:
> On Sat, Aug 19, 2017 at 2:37 AM, Koichiro Den <den@klaipeden.com> wrote:
> > The module param napi_tx needs not to be writable for now since we do
> > not have any means of activating/deactivating it online,
> 
> A virtio_net device inherits its napi tx mode from the global napi_tx flag
> on device up. It is possible to change the parameter and bring a device
> down/up to change the device mode.
> 
> > @@ -1179,13 +1172,19 @@ static int virtnet_open(struct net_device *dev)
> >         struct virtnet_info *vi = netdev_priv(dev);
> >         int i;
> > 
> > +       /* Tx napi touches cachelines on the cpu handling tx interrupts.
> > Only
> > +        * enable the feature if this is likely affine with the transmit
> > path.
> > +        */
> > +       if (!vi->affinity_hint_set)
> > +               napi_tx = false;
> > +
> 
> This disables napi globally if a specific device lacks affinity.
Now I see this is not appropriate since it just represents whether or not TX
napi is available, not that whether or not it is being turned on or off on a
particular device. Thank you.

To be honest I hoped to make it possible to see which mode it is currently
running on with ease, but I guess it's not nice to accomplish it with net sysfs
nor ethtool or whatever because it seems not much generic matter.

Thanks.
