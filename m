From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: core: let skb_partial_csum_set() set
 transport header
Date: Wed, 27 Mar 2013 13:07:38 -0400 (EDT)
Message-ID: <20130327.130738.1384912506225105640.davem@davemloft.net>
References: <1364375482-7439-1-git-send-email-jasowang@redhat.com>
	<1364395376.15753.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364395376.15753.5.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Mar 2013 07:42:56 -0700

> On Wed, 2013-03-27 at 17:11 +0800, Jason Wang wrote:
>> For untrusted packets with partial checksum, we need to set the transport header
>> for precise packet length estimation. We can just let skb_pratial_csum_set() to
>> do this to avoid extra call to skb_flow_dissect() and simplify the caller.
>> 
>> Cc: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  net/core/skbuff.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>> 
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 31c6737..ba64614 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -3370,6 +3370,7 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off)
>>  	skb->ip_summed = CHECKSUM_PARTIAL;
>>  	skb->csum_start = skb_headroom(skb) + start;
>>  	skb->csum_offset = off;
>> +	skb_set_transport_header(skb, start);
>>  	return true;
>>  }
>>  EXPORT_SYMBOL_GPL(skb_partial_csum_set);
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
