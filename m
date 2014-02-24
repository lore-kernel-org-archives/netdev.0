From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v5 2/9] xen-netback: Change TX path from grant
 copy to mapping
Date: Mon, 24 Feb 2014 16:56:05 +0000
Message-ID: <530B79A5.7010600@citrix.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>	 <1390253069-25507-3-git-send-email-zoltan.kiss@citrix.com> <1392745235.23084.60.camel@kazak.uk.xensource.com> <530925D5.4010800@schaman.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@schaman.hu>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <530925D5.4010800@schaman.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/02/14 22:33, Zoltan Kiss wrote:
> On 18/02/14 17:40, Ian Campbell wrote:
>> +     */
>>> +    skb->pfmemalloc    = false;
>>>   }
>>>
>>>   static int xenvif_get_extras(struct xenvif *vif,
>>> @@ -1372,7 +1341,7 @@ static bool tx_credit_exceeded(struct xenvif 
>>> *vif, unsigned size)
>>
>>> @@ -1581,7 +1535,11 @@ static int xenvif_tx_submit(struct xenvif *vif)
>>>           else if (txp->flags & XEN_NETTXF_data_validated)
>>>               skb->ip_summed = CHECKSUM_UNNECESSARY;
>>>
>>> -        xenvif_fill_frags(vif, skb);
>>> +        xenvif_fill_frags(vif,
>>> +                  skb,
>>> +                  skb_shinfo(skb)->destructor_arg ?
>>> +                  pending_idx :
>>> +                  INVALID_PENDING_IDX
>>
>> Couldn't xenvif_fill_frags calculate the 3rd argument itself given that
>> it has skb in hand.
> We still have to pass pending_idx, as it is no longer in skb->data. I 
> have plans (I've already prototyped it, actually) to move that 
> pending_idx from skb->data to skb->cb, if that happens, this won't be 
> necessary.
> On the other hand, it makes more sense just to just pass pending_idx, 
> and in fill_frags we can decide based on destructor_arg whether do we 
> need it or not.
Actually, I've just moved the skb->cb patch to the beginning of this 
series, so we can completely omit that new parameter from fill_frags.

Zoli
