From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2 3/3] tun: rx batching
Date: Fri, 30 Dec 2016 13:14:33 +0800
Message-ID: <d7d1378d-2051-d962-8001-d63085c3e1bc@redhat.com>
References: <1482912571-3157-1-git-send-email-jasowang@redhat.com>
 <1482912571-3157-4-git-send-email-jasowang@redhat.com>
 <20161229.113506.1833529555874695164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: mst@redhat.com, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161229.113506.1833529555874695164.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016年12月30日 00:35, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Wed, 28 Dec 2016 16:09:31 +0800
>
>> +	spin_lock(&queue->lock);
>> +	qlen = skb_queue_len(queue);
>> +	if (qlen > rx_batched)
>> +		goto drop;
>> +	__skb_queue_tail(queue, skb);
>> +	if (!more || qlen + 1 > rx_batched) {
>> +		__skb_queue_head_init(&process_queue);
>> +		skb_queue_splice_tail_init(queue, &process_queue);
>> +		rcv = true;
>> +	}
>> +	spin_unlock(&queue->lock);
> Since you always clear the 'queue' when you insert the skb that hits
> the limit, I don't see how the "goto drop" path can be possibly taken.

True, will fix this.

Thanks
