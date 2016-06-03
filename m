From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC v7 1/5] ptr_ring: array based FIFO for pointers
Date: Fri, 3 Jun 2016 19:38:49 +0200
Message-ID: <20160603193849.6c9c040d@redhat.com>
References: <1464883305-32368-1-git-send-email-mst@redhat.com>
	<1464883305-32368-2-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	kvm@vger.kernel.org, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37826 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932207AbcFCRiy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2016 13:38:54 -0400
In-Reply-To: <1464883305-32368-2-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2 Jun 2016 19:08:18 +0300 "Michael S. Tsirkin" <mst@redhat.com> wrote:

> A simple array based FIFO of pointers.  Intended for net stack which
> commonly has a single consumer/producer.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  include/linux/ptr_ring.h | 264 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 264 insertions(+)
>  create mode 100644 include/linux/ptr_ring.h
> 
> diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
> new file mode 100644
> index 0000000..d265d72
> --- /dev/null
> +++ b/include/linux/ptr_ring.h
[...]
> +static inline void *ptr_ring_consume_bh(struct ptr_ring *r)
                                       ^^^
> +{
> +	void *ptr;
> +
> +	spin_lock(&r->consumer_lock);

Ups! should have been spin_lock_bh()

> +	ptr = __ptr_ring_consume(r);
> +	spin_unlock(&r->consumer_lock);

and spin_unlock_bh()

> +
> +	return ptr;
> +}



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
