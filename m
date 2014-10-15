From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH net-next 5/6] virtio-net: enable tx interrupt
Date: Wed, 15 Oct 2014 18:21:44 +0800
Message-ID: <543E4AB8.6090005@redhat.com>
References: <1413357930-45302-1-git-send-email-jasowang@redhat.com>	
	<1413357930-45302-6-git-send-email-jasowang@redhat.com>
	<1413365865.12304.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1413365865.12304.55.camel@edumazet-glaptop2.roam.corp.google.com>
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

On 10/15/2014 05:37 PM, Eric Dumazet wrote:
> On Wed, 2014-10-15 at 15:25 +0800, Jason Wang wrote:
>
> ...
>
>> +static int free_old_xmit_skbs(struct send_queue *sq, int budget)
>> +{
>> +	struct sk_buff *skb;
>> +	unsigned int len;
>> +	struct virtnet_info *vi = sq->vq->vdev->priv;
>> +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>> +	u64 tx_bytes = 0, tx_packets = 0;
>> +
>> +	while (tx_packets < budget &&
>> +	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
>> +		pr_debug("Sent skb %p\n", skb);
>> +
>> +		tx_bytes += skb->len;
>> +		tx_packets++;
>> +
>> +		dev_kfree_skb_any(skb);
>> +	}
>> +
>> +	u64_stats_update_begin(&stats->tx_syncp);
>> +	stats->tx_bytes += tx_bytes;
>> +	stats->tx_packets =+ tx_packets;
> 	
> 	stats->tx_packets += tx_packets;

My bad, will correct it in next version.

Thanks
