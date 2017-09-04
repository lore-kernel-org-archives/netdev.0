From: Radu Rendec <rrendec@arista.com>
Subject: Re: virtio_net: ethtool supported link modes
Date: Mon, 04 Sep 2017 15:59:13 +0100
Message-ID: <1504537153.7242.6.camel@arista.com>
References: <1504199044.22080.11.camel@arista.com>
         <20170901183517-mutt-send-email-mst@kernel.org>
         <1504282793.12952.17.camel@arista.com>
         <20170901204222-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
        virtio-dev@lists.oasis-open.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901204222-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-09-01 at 20:45 +0300, Michael S. Tsirkin wrote:
> On Fri, Sep 01, 2017 at 05:19:53PM +0100, Radu Rendec wrote:
> > On Fri, 2017-09-01 at 18:43 +0300, Michael S. Tsirkin wrote:
> > > On Thu, Aug 31, 2017 at 06:04:04PM +0100, Radu Rendec wrote:
> > > > Looking at the code in virtnet_set_link_ksettings, it seems the speed
> > > > and duplex can be set to any valid value. The driver will "remember"
> > > > them and report them back in virtnet_get_link_ksettings.
> > > > 
> > > > However, the supported link modes (link_modes.supported in struct
> > > > ethtool_link_ksettings) is always 0, indicating that no speed/duplex
> > > > setting is supported.
> > > > 
> > > > Does it make more sense to set (at least a few of) the supported link
> > > > modes, such as 10baseT_Half ... 10000baseT_Full?
> > > > 
> > > > I would expect to see consistency between what is reported in
> > > > link_modes.supported and what can actually be set. Could you please
> > > > share your opinion on this?
> > 
> > The use case behind my original question is very simple:
> >  * Net device is queried via ethtool for supported modes.
> >  * Supported modes are presented to user.
> >  * User can configure any of the supported modes.
> 
> Since this has no effect on virtio, isn't presenting
> "no supported modes" to user the right thing to do?

Yes, that makes sense.

> > This is done transparently to the net device type (driver), so it
> > actually makes sense for physical NICs.
> > 
> > This alone of course is not a good enough motivation to modify the
> > driver. And it can be easily addressed in user-space at the application
> > level by testing for the driver.
> 
> I think you might want to special-case no supported modes.
> Special-casing virtio is probably best avoided.
> 
> > I was merely trying to avoid driver-specific workarounds (i.e. keep the
> > application driver agnostic)
> 
> I think that's the right approach. So if driver does not present
> any supported modes this probably means it is not necessary
> to display or program any.

Yes, apparently it boils down to special-casing no supported modes.
This avoids both modifying virtio and special-casing virtio, and keeps
the application driver-agnostic at the same time.

Thanks for all the feedback. It was very helpful in figuring out the
right approach. I really appreciate it.

Radu
