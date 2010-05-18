From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio: put last seen used index into ring itself
Date: Tue, 18 May 2010 13:25:45 +0300
Message-ID: <20100518102545.GA26338@redhat.com>
References: <20100518004744.GA21359@redhat.com> <4BF26B87.3080902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Jiri Pirko <jpirko@redhat.com>, Shirley Ma <xma@us.ibm.com>,
	Amit Shah <amit.shah@redhat.com>,
	Mark McLoughlin <markmc@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, quintela@redhat.com,
	alex.williamson@redhat.com
To: Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14866 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757152Ab0ERKaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 06:30:01 -0400
Content-Disposition: inline
In-Reply-To: <4BF26B87.3080902@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 18, 2010 at 12:27:19PM +0200, Jes Sorensen wrote:
> On 05/18/10 02:47, Michael S. Tsirkin wrote:
> > Generally, the Host end of the virtio ring doesn't need to see where
> > Guest is up to in consuming the ring.  However, to completely understand
> > what's going on from the outside, this information must be exposed.
> > For example, host can reduce the number of interrupts by detecting
> > that the guest is currently handling previous buffers.
> > 
> > Fortunately, we have room to expand: the ring is always a whole number
> > of pages and there's hundreds of bytes of padding after the avail ring
> > and the used ring, whatever the number of descriptors (which must be a
> > power of 2).
> 
> Hi Michael,
> 
> Small build fix for this against Linus upstream.
> 
> Jes
> 
> 
> Fix build of virtio_net.c
> 
> Signed-off-by: Jes.Sorensen@redhat.com

Thanks, this is already fixed in v2 that I sent.

> ---
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index d37e5be..679e2df 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -23,6 +23,7 @@
>  #include <linux/module.h>
>  #include <linux/virtio.h>
>  #include <linux/virtio_net.h>
> +#include <linux/virtio_ring.h>
>  #include <linux/scatterlist.h>
>  #include <linux/if_vlan.h>
>  #include <linux/slab.h>
> 
