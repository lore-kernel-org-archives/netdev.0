From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 7/8] vhost_net: try batch dequing from skb array
Date: Wed, 29 Mar 2017 17:58:23 +0800
Message-ID: <bf511f4a-b1d0-d732-a01e-9cd4b8ae6817@redhat.com>
References: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
 <1490069087-4783-8-git-send-email-jasowang@redhat.com>
 <20170322155111-mutt-send-email-mst@kernel.org>
 <f41bb12f-10d6-9fb2-1cd2-76e3e9460aff@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36824 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755154AbdC2J6k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 05:58:40 -0400
In-Reply-To: <f41bb12f-10d6-9fb2-1cd2-76e3e9460aff@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年03月23日 13:34, Jason Wang wrote:
>
>
>>
>>> +{
>>> +    if (rvq->rh != rvq->rt)
>>> +        goto out;
>>> +
>>> +    rvq->rh = rvq->rt = 0;
>>> +    rvq->rt = skb_array_consume_batched_bh(rvq->rx_array, rvq->rxq,
>>> +                        VHOST_RX_BATCH);
>> A comment explaining why is is -bh would be helpful.
>
> Ok.
>
> Thanks 

Rethink about this. It looks like -bh is not needed in this case since 
no consumer run in bh.

Thanks
