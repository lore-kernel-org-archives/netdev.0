From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Thu, 17 Mar 2011 08:18:35 -0700
Message-ID: <1300375115.3255.45.camel@localhost.localdomain>
References: <1300320775.3255.34.camel@localhost.localdomain>
	 <20110317050242.GC32049@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110317050242.GC32049@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-03-17 at 07:02 +0200, Michael S. Tsirkin wrote:
> So, this just tries to make sure there's enough space for
> max packet in the ring, if not - drop and return OK.
> Why bother checking beforehand though?
> If that's what we want to do, we can just call add_buf and see
> if it fails?

In add_buf, there is an additional kick, see below. I added check
capacity to avoid this, thought it would be better performance. I will
retest it w/i add_buf to see the performance difference.

        if (vq->num_free < out + in) {
                pr_debug("Can't add buf len %i - avail = %i\n",
                         out + in, vq->num_free);
                /* FIXME: for historical reasons, we force a notify here
if
                 * there are outgoing parts to the buffer.  Presumably
the
                 * host should service the ring ASAP. */
                if (out)
                        vq->notify(&vq->vq);
                END_USE(vq);
                return -ENOSPC;
        }

Thanks
Shirley

