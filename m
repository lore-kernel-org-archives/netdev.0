From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 3/3] tun: rx batching
Date: Thu, 29 Dec 2016 11:35:06 -0500 (EST)
Message-ID: <20161229.113506.1833529555874695164.davem@davemloft.net>
References: <1482912571-3157-1-git-send-email-jasowang@redhat.com>
	<1482912571-3157-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482912571-3157-4-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 28 Dec 2016 16:09:31 +0800

> +	spin_lock(&queue->lock);
> +	qlen = skb_queue_len(queue);
> +	if (qlen > rx_batched)
> +		goto drop;
> +	__skb_queue_tail(queue, skb);
> +	if (!more || qlen + 1 > rx_batched) {
> +		__skb_queue_head_init(&process_queue);
> +		skb_queue_splice_tail_init(queue, &process_queue);
> +		rcv = true;
> +	}
> +	spin_unlock(&queue->lock);

Since you always clear the 'queue' when you insert the skb that hits
the limit, I don't see how the "goto drop" path can be possibly taken.
