From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC v7 3/5] skb_array: array based FIFO for skbs
Date: Fri, 3 Jun 2016 19:05:40 +0200
Message-ID: <20160603190540.79421e54@redhat.com>
References: <1464883305-32368-1-git-send-email-mst@redhat.com>
	<1464883305-32368-4-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	kvm@vger.kernel.org, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464883305-32368-4-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Could not compile this new version of skb_array.h, it complains about
implicit declaration of function 'skb_vlan_tag_present' and
'VLAN_HLEN' being undeclared.

Fix this by including linux/if_vlan.h, but is that correct?


On Thu, 2 Jun 2016 19:08:26 +0300 "Michael S. Tsirkin" <mst@redhat.com> wrote:

> A simple array based FIFO of pointers.  Intended for net stack so uses
> skbs for type safety. Implemented as a set of wrappers around ptr_array.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  include/linux/skb_array.h | 143 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 143 insertions(+)
>  create mode 100644 include/linux/skb_array.h
> 
> diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
> new file mode 100644
> index 0000000..ed6a2b5
> --- /dev/null
> +++ b/include/linux/skb_array.h
> @@ -0,0 +1,143 @@
[...]
> +
> +#ifndef _LINUX_SKB_ARRAY_H
> +#define _LINUX_SKB_ARRAY_H 1
> +
> +#ifdef __KERNEL__
> +#include <linux/ptr_ring.h>
> +#include <linux/skbuff.h>

Added:
+#include <linux/if_vlan.h>


> +#endif

[...]
> +static inline int __skb_array_len_with_tag(struct sk_buff *skb)
> +{
> +	if (likely(skb)) {
> +		int len = skb->len;
> +
> +		if (skb_vlan_tag_present(skb))
> +			len += VLAN_HLEN;
> +
> +		return len;
> +	} else {
> +		return 0;
> +	}
> +}
> +
> +static inline int skb_array_peek_len(struct skb_array *a)
> +{
> +	return PTR_RING_PEEK_CALL(&a->ring, __skb_array_len_with_tag);
> +}
> +
[...]

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
