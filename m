From: Radu Rendec <rrendec@arista.com>
Subject: Re: virtio_net: ethtool supported link modes
Date: Fri, 01 Sep 2017 17:19:53 +0100
Message-ID: <1504282793.12952.17.camel@arista.com>
References: <1504199044.22080.11.camel@arista.com>
         <20170901183517-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
        virtio-dev@lists.oasis-open.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901183517-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-09-01 at 18:43 +0300, Michael S. Tsirkin wrote:
> On Thu, Aug 31, 2017 at 06:04:04PM +0100, Radu Rendec wrote:
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
> I would like to know more about why this is desirable.
> 
> We used not to support the modes at all, but it turned out
> some tools are confused by this: e.g. people would try to
> bond virtio with a hardware device, tools would see
> a mismatch in speed and features between bonded devices
> and get confused.
> 
> See
> 
> 	commit 16032be56c1f66770da15cb94f0eb366c37aff6e
> 	Author: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 	Date:   Wed Feb 3 04:04:37 2016 +0100
> 
> 	    virtio_net: add ethtool support for set and get of settings
> 
> 
> as well as the discussion around it
> 	https://www.spinics.net/lists/netdev/msg362111.html

Thanks for pointing these out. It is much more clear now why modes
support is implemented the way it is and what the expectations are.

> If you think we need to add more hacks like this, a stronger
> motivation than "to see consistency" would be needed.

The use case behind my original question is very simple:
 * Net device is queried via ethtool for supported modes.
 * Supported modes are presented to user.
 * User can configure any of the supported modes.

This is done transparently to the net device type (driver), so it
actually makes sense for physical NICs.

This alone of course is not a good enough motivation to modify the
driver. And it can be easily addressed in user-space at the application
level by testing for the driver.

I was merely trying to avoid driver-specific workarounds (i.e. keep the
application driver agnostic) and wondered if "advertising" supported
modes through ethtool made any sense and/or would be a desirable change
from the driver perspective. I believe I have my answers now.

Thanks,
Radu
