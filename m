From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: make napi_tx param easier to grasp
Date: Sun, 20 Aug 2017 16:30:38 -0400
Message-ID: <CAF=yD-JA_JPyUbDd=SR9Epvzw6-kbUcrfvwRWODwmeV+yHEMHw@mail.gmail.com>
References: <20170819063707.26822-1-den@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:37804 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753191AbdHTUbU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 16:31:20 -0400
Received: by mail-oi0-f68.google.com with SMTP id k77so283560oib.4
        for <netdev@vger.kernel.org>; Sun, 20 Aug 2017 13:31:20 -0700 (PDT)
In-Reply-To: <20170819063707.26822-1-den@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 19, 2017 at 2:37 AM, Koichiro Den <den@klaipeden.com> wrote:
> The module param napi_tx needs not to be writable for now since we do
> not have any means of activating/deactivating it online,

A virtio_net device inherits its napi tx mode from the global napi_tx flag
on device up. It is possible to change the parameter and bring a device
down/up to change the device mode.

> @@ -1179,13 +1172,19 @@ static int virtnet_open(struct net_device *dev)
>         struct virtnet_info *vi = netdev_priv(dev);
>         int i;
>
> +       /* Tx napi touches cachelines on the cpu handling tx interrupts. Only
> +        * enable the feature if this is likely affine with the transmit path.
> +        */
> +       if (!vi->affinity_hint_set)
> +               napi_tx = false;
> +

This disables napi globally if a specific device lacks affinity.
