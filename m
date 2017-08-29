From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 2/2] virtio_net: enable probing for NEEDS_RESET
 support
Date: Tue, 29 Aug 2017 23:38:06 +0300
Message-ID: <20170829233525-mutt-send-email-mst@kernel.org>
References: <20170829200759.13975-1-willemdebruijn.kernel@gmail.com>
 <20170829200759.13975-3-willemdebruijn.kernel@gmail.com>
 <20170829231606-mutt-send-email-mst@kernel.org>
 <CAF=yD-L95x1EPKFeiPiZ2hbTzwYmDaG9O54+0tUW_4opuRKDMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46978 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750909AbdH2UiH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 16:38:07 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-L95x1EPKFeiPiZ2hbTzwYmDaG9O54+0tUW_4opuRKDMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 04:27:41PM -0400, Willem de Bruijn wrote:
> On Tue, Aug 29, 2017 at 4:16 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Tue, Aug 29, 2017 at 04:07:59PM -0400, Willem de Bruijn wrote:
> >> From: Willem de Bruijn <willemb@google.com>
> >>
> >> Implement a mechanism to signal that a virtio device implements the
> >> VIRTIO_CONFIG_S_NEEDS_RESET command.
> >>
> >> Testing for VIRTIO_CONFIG_S_NEEDS_RESET support by issuing the request
> >> and verifying the reset state would require an expensive state change.
> >>
> >> To avoid that, add a status bit to the feature register used during
> >> feature negotiation between host and guest.
> >>
> >> Set the bit for virtio-net, which supports the feature.
> >>
> >> Signed-off-by: Willem de Bruijn <willemb@google.com>
> >
> > All virtio 1 devices have the reset feature
> 
> I don't quite follow. No device drivers implement this request currently?

Depends. Spec 1.0 describes the bit and that driver can respond
by reseting the device. You seem to do something else
in this patchset, but as designed in 1.0 it does not seem to need
a feature bit.

> > so maybe guest does
> > not need this flag. Does device need it? Does device really
> > care that guest can't recover?
> 
> If all device drivers support it, then the flag is not needed.
> 
> But as long as legacy device drivers can exist that do not support
> this feature, it has to have a way of differentiating between the two.

Why? Device won't set this unless it's in a bad state. In that case,
setting the bit is harmless even if drivers ignore it.

-- 
MST
