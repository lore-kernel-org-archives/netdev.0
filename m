From: Radu Rendec <rrendec@arista.com>
Subject: Re: virtio_net: ethtool supported link modes
Date: Fri, 01 Sep 2017 13:01:34 +0100
Message-ID: <1504267294.12952.5.camel@arista.com>
References: <1504199044.22080.11.camel@arista.com>
         <38286395-683f-f285-aaa5-68f0e8b68675@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34824 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751752AbdIAMBh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 08:01:37 -0400
Received: by mail-wm0-f41.google.com with SMTP id v2so143407wmf.0
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 05:01:36 -0700 (PDT)
In-Reply-To: <38286395-683f-f285-aaa5-68f0e8b68675@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-01 at 11:36 +0800, Jason Wang wrote:
> 
> On 2017年09月01日 01:04, Radu Rendec wrote:
> > Hello,
> > 
> > Looking at the code in virtnet_set_link_ksettings, it seems the speed
> > and duplex can be set to any valid value. The driver will "remember"
> > them and report them back in virtnet_get_link_ksettings.
> > 
> > However, the supported link modes (link_modes.supported in struct
> > ethtool_link_ksettings) is always 0, indicating that no speed/duplex
> > setting is supported.
> > 
> > Does it make more sense to set (at least a few of) the supported link
> > modes, such as 10baseT_Half ... 10000baseT_Full?
> > 
> > I would expect to see consistency between what is reported in
> > link_modes.supported and what can actually be set. Could you please
> > share your opinion on this?
> 
> I think the may make sense only if there's a hardware implementation for 
> virtio. And we probably need to extend virtio spec for adding new commands.

So you're saying that the "hardware" should provide the supported link
modes (e.g. by using feature bits at the virtio layer) and the
virtio_net driver should just translate them and expose them as
link_modes.supported?

Then for consistency, I assume setting speed/duplex via ethtool should
also go into the virtio layer (currently virtio_net seems to just store
them for future retrieval via ethtool).

Thanks,
Radu
