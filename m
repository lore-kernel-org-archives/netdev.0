From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v3 6/9] xen-netback: Handle guests with too many
 frags
Date: Wed, 8 Jan 2014 13:49:57 +0000
Message-ID: <52CD5785.4050402@citrix.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>	 <1389139818-24458-7-git-send-email-zoltan.kiss@citrix.com> <1389147141.26646.74.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389147141.26646.74.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/01/14 02:12, Eric Dumazet wrote:
> On Wed, 2014-01-08 at 00:10 +0000, Zoltan Kiss wrote:
>
>>
>> +		if (skb_shinfo(skb)->frag_list) {
>> +			nskb = skb_shinfo(skb)->frag_list;
>> +			xenvif_fill_frags(vif, nskb, INVALID_PENDING_IDX);
>> +			skb->len += nskb->len;
>> +			skb->data_len += nskb->len;
>> +			skb->truesize += nskb->truesize;
>> +			skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>> +			skb_shinfo(nskb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>> +			vif->tx_zerocopy_sent += 2;
>> +			nskb = skb;
>> +
>> +			skb = skb_copy_expand(skb,
>> +					0,
>> +					0,
>> +					GFP_ATOMIC | __GFP_NOWARN);
>
> skb can be NULL here

Thanks, fixed that.

Zoli
