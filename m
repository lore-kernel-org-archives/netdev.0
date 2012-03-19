From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [V4 PATCH] virtio-net: send gratuitous packet when needed
Date: Mon, 19 Mar 2012 12:46:29 +1030
Message-ID: <877gyhxrlu.fsf@rustcorp.com.au>
References: <20120313090841.11110.82654.stgit@amd-6168-8-1.englab.nay.redhat.com> <20120313143331.GE14931@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120313143331.GE14931@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Mar 2012 16:33:31 +0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> > index 970d5a2..44a38d6 100644
> > --- a/include/linux/virtio_net.h
> > +++ b/include/linux/virtio_net.h
> > @@ -49,8 +49,10 @@
> >  #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
> >  #define VIRTIO_NET_F_CTRL_VLAN	19	/* Control channel VLAN filtering */
> >  #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
> > +#define VIRTIO_NET_F_GUEST_ANNOUNCE 21  /* Guest can send gratituous packet */
> >  
> >  #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
> > +#define VIRTIO_NET_S_ANNOUNCE   2       /* Announcement is needed */
> 
> I would put this in bit 8 (0x100), this way low status byte
> is RO, high byte is RW.

The whole idea of acking by clearing the bit is unreliable, moving to a
separate byte just controls the damage.

How about you use bits 8-15 as a counter?  It's still theoretically
unreliable if 256 notifications pass before the guest notices, but it's
probably better and clearer than this.

I leave the final call to MST though.

Thanks,
Rusty.
-- 
  How could I marry someone with more hair than me?  http://baldalex.org
