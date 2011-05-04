From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/4] [RFC] virtio: Introduce new API to get free space
Date: Wed, 4 May 2011 22:58:18 +0300
Message-ID: <20110504195818.GA20255@redhat.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
 <20110504140319.14817.23145.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au, mashirle@us.ibm.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110504140319.14817.23145.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 04, 2011 at 07:33:19PM +0530, Krishna Kumar wrote:
> @@ -185,11 +193,6 @@ int virtqueue_add_buf_gfp(struct virtque
>  	if (vq->num_free < out + in) {
>  		pr_debug("Can't add buf len %i - avail = %i\n",
>  			 out + in, vq->num_free);
> -		/* FIXME: for historical reasons, we force a notify here if
> -		 * there are outgoing parts to the buffer.  Presumably the
> -		 * host should service the ring ASAP. */
> -		if (out)
> -			vq->notify(&vq->vq);
>  		END_USE(vq);
>  		return -ENOSPC;
>  	}

I thought about it some more.  We should typically not get into this
state with the current driver as we check capacity upfront.

So why would this change help performance?
Shirley, any idea?

-- 
MST
