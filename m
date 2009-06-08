From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH qemu-kvm] Enable UFO on virtio-net/tap devices
Date: Mon, 08 Jun 2009 09:40:52 -0700
Message-ID: <1244479252.18220.12.camel@w-sridhar.beaverton.ibm.com>
References: <1244247408.1526.174.camel@w-sridhar.beaverton.ibm.com>
	 <4A2B5C73.5050907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, herbert.xu@redhat.com, rusty@rustcorp.com.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A2B5C73.5050907@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2009-06-07 at 09:21 +0300, Avi Kivity wrote:
> Sridhar Samudrala wrote:
> > Enable UFO on the host tap device if supported and allow setting UFO
> > on virtio-net in the guest.
> >
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> >
> >
> > diff --git a/hw/virtio-net.c b/hw/virtio-net.c
> > index 3c77b99..8a53e27 100644
> > --- a/hw/virtio-net.c
> > +++ b/hw/virtio-net.c
> > @@ -134,7 +134,8 @@ static uint32_t virtio_net_get_features(VirtIODevice *vdev)
> >          features |= (1 << VIRTIO_NET_F_HOST_TSO6);
> >          features |= (1 << VIRTIO_NET_F_HOST_ECN);
> >          features |= (1 << VIRTIO_NET_F_MRG_RXBUF);
> > -        /* Kernel can't actually handle UFO in software currently. */
> > +       // features |= (1 << VIRTIO_NET_F_HOST_UFO);
> > +        features |= (1 << VIRTIO_NET_F_GUEST_UFO);
> >   
> 
> Where are these defined?

They are in hw/virtio_net.h

> 
> > @@ -990,8 +990,13 @@ static int tap_probe_vnet_hdr(int fd)
> >  }
> >  
> >  #ifdef TUNSETOFFLOAD
> > +
> > +#ifndef TUN_F_UFO
> > +#define TUN_F_UFO	0x10
> > +#endif
> > +
> >   
> 
> Should just use the definition in the kernel header.
> 
TUN_F_UFO is not defined in the current version of kernel header linux/if_tun.h.
I have added this in my kernel patches to support UFO.
So until this definition gets into the distro versions of kernel headers, i think
we need to have this defined in qemu.

Thanks
Sridhar

