From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 0/5] batched tx processing in vhost_net
Date: Wed, 27 Sep 2017 10:06:43 +0800
Message-ID: <c7050021-4218-32ea-bf74-149f2ff2e1ea@redhat.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <20170926222528-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926222528-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月27日 03:26, Michael S. Tsirkin wrote:
> On Fri, Sep 22, 2017 at 04:02:30PM +0800, Jason Wang wrote:
>> Hi:
>>
>> This series tries to implement basic tx batched processing. This is
>> done by prefetching descriptor indices and update used ring in a
>> batch. This intends to speed up used ring updating and improve the
>> cache utilization. Test shows about ~22% improvement in tx pss.
>
>
>
>> Please review.
>>
>> Jason Wang (5):
>>    vhost: split out ring head fetching logic
>>    vhost: introduce helper to prefetch desc index
>>    vhost: introduce vhost_add_used_idx()
> Please squash these new APIs into where they are used.
> This split-up just makes review harder for me as
> I can't figure out how the new APIs are used.

Ok.

Thanks

>
>
>>    vhost_net: rename VHOST_RX_BATCH to VHOST_NET_BATCH
> This is ok as a separate patch.
>
>>    vhost_net: basic tx virtqueue batched processing
>>
>>   drivers/vhost/net.c   | 221 ++++++++++++++++++++++++++++----------------------
>>   drivers/vhost/vhost.c | 165 +++++++++++++++++++++++++++++++------
>>   drivers/vhost/vhost.h |   9 ++
>>   3 files changed, 270 insertions(+), 125 deletions(-)
>>
>> -- 
>> 2.7.4
