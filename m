From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers
 and big packets in virtio_net
Date: Mon, 23 Nov 2009 15:27:15 -0800
Message-ID: <1259018835.5022.64.camel@localhost.localdomain>
References: <1258697745.7416.20.camel@localhost.localdomain>
	 <200911231138.30755.rusty@rustcorp.com.au>
	 <1258992421.5022.19.camel@localhost.localdomain>
	 <200911240854.24054.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hollis Blanchard <hollisb@us.ibm.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:60738 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756371AbZKWX1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 18:27:13 -0500
In-Reply-To: <200911240854.24054.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-24 at 08:54 +1030, Rusty Russell wrote:
> #define BIG_PACKET_PAD (NET_SKB_PAD - sizeof(struct virtio_net_hdr) +
> NET_IP_ALIGN)
> struct big_packet_page {
>         struct virtio_net_hdr hdr;
>         char pad[BIG_PACKET_PAD];
>         /* Actual packet data starts here */
>         unsigned char data[PAGE_SIZE - BIG_PACKET_PAD - sizeof(struct
> virtio_net_hdr)];
> };

The padding was used for qemu userspace buffer copy, skb data is copied
from the page for size of GOOD_COPY_LEN, and skb data is reserved
NET_IP_ALIGN.

If we add paddings as above, userspace copy will starts NET_SKB_PAD +
NET_IP_ALIGN? I am little bit confused here.

> Then use this type as the template for registering the sg list for the
> big packet case.
> 
> > > I think you can move the memcpy outside the if, like so:
> > > 
> > >         memcpy(&hdr, p, hdr_len);
> > 
> > I didn't move it out, because num_buf = hdr->mhdr.num_buffers;
> 
> Yes, that has to stay inside, but the memcpy can move out.  It's just
> a bit
> neater to have more common code.

num_buf is assigned after memcpy so we couldn't move memcpy out.

Anyway I separated mergeable buffers and big packets in the new patch to
make it clear and it will be easy to modify when we drop big packets
support in the future.

Thanks
Shirley

