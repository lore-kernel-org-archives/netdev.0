From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 2/5] vhost: introduce helper to prefetch desc
 index
Date: Mon, 25 Sep 2017 10:04:13 +0800
Message-ID: <33bdcceb-9f12-e5e9-4b4d-6d619e17a206@redhat.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <1506067355-5771-3-git-send-email-jasowang@redhat.com>
 <20170922090257.GB9243@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: mst@redhat.com, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kvm@vger.kernel.org
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922090257.GB9243@stefanha-x1.localdomain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月22日 17:02, Stefan Hajnoczi wrote:
> On Fri, Sep 22, 2017 at 04:02:32PM +0800, Jason Wang wrote:
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index f87ec75..8424166d 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -2437,6 +2437,61 @@ struct vhost_msg_node *vhost_dequeue_msg(struct vhost_dev *dev,
>>   }
>>   EXPORT_SYMBOL_GPL(vhost_dequeue_msg);
>>   
>> +int vhost_prefetch_desc_indices(struct vhost_virtqueue *vq,
>> +				struct vring_used_elem *heads,
>> +				u16 num, bool used_update)
> Missing doc comment.

Will fix this.

>
>> +{
>> +	int ret, ret2;
>> +	u16 last_avail_idx, last_used_idx, total, copied;
>> +	__virtio16 avail_idx;
>> +	struct vring_used_elem __user *used;
>> +	int i;
> The following variable names are a little confusing:
>
> last_avail_idx vs vq->last_avail_idx.  last_avail_idx is a wrapped
> avail->ring[] index, vq->last_avail_idx is a free-running counter.  The
> same for last_used_idx vs vq->last_used_idx.
>
> num argument vs vq->num.  The argument could be called nheads instead to
> make it clear that this is heads[] and not the virtqueue size.
>
> Not a bug but it took me a while to figure out what was going on.

I admit the name is confusing. Let me try better ones in V2.

Thanks
