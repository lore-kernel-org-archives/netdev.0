From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/8] net: Clarification of CHECKSUM_UNNECESSARY
Date: Wed, 27 Aug 2014 14:40:01 -0700 (PDT)
Message-ID: <20140827.144001.80733091766338046.davem@davemloft.net>
References: <20140825.181341.304248903530349010.davem@davemloft.net>
	<CA+mtBx8iv8tWU0mmEQEWxDfp614Hh=cQOpXqxSdhHaGsH6sBDA@mail.gmail.com>
	<CA+mtBx9GvHpLJ718hV5BjRGjfWvmXB55hKa3Rwo=6me3f0M3Dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964792AbaH0VkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 17:40:03 -0400
In-Reply-To: <CA+mtBx9GvHpLJ718hV5BjRGjfWvmXB55hKa3Rwo=6me3f0M3Dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 25 Aug 2014 18:47:35 -0700

> On Mon, Aug 25, 2014 at 6:40 PM, Tom Herbert <therbert@google.com> wrote:
>> On Mon, Aug 25, 2014 at 6:13 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Tom Herbert <therbert@google.com>
>>> Date: Mon, 25 Aug 2014 17:55:56 -0700 (PDT)
>>>
>>>> @@ -569,16 +590,13 @@ struct sk_buff {
>>>>       __u8                    wifi_acked:1;
>>>>       __u8                    no_fcs:1;
>>>>       __u8                    head_frag:1;
>>>> -     /* Encapsulation protocol and NIC drivers should use
>>>> -      * this flag to indicate to each other if the skb contains
>>>> -      * encapsulated packet or not and maybe use the inner packet
>>>> -      * headers if needed
>>>> -      */
>>>> +     /* Indicates the the inner headers are valid in the skbuff. */
>>>>       __u8                    encapsulation:1;
>>>>       __u8                    encap_hdr_csum:1;
>>>>       __u8                    csum_valid:1;
>>>>       __u8                    csum_complete_sw:1;
>>>> -     /* 2/4 bit hole (depending on ndisc_nodetype presence) */
>>>> +     __u8                    csum_level:2;
>>>> +     /* 0/2 bit hole (depending on ndisc_nodetype presence) */
>>>>       kmemcheck_bitfield_end(flags2);
>>>
>>> Crap, with xmit_more, this actually bleeds us over into a new __u8.
>>
>> We'll undoubtably want to add more flags beyond that (they're quite
>> useful). I'll try to find some more space in the existing fields so we
>> don't increase skbuf size.
> 
> Actually, from inner_protocol through mac_header there are seven 16
> bit fields, could put another 16 bit flags there.

Ok, please resubmit this series with that change.

Meanwhile I fixed up the comment so that it's accurate again, like so:

====================
Subject: [PATCH] net: Update sk_buff flag bit availability comment.

We lost one when xmit_more was added.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9b3802a..b69b7b5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -580,7 +580,7 @@ struct sk_buff {
 	__u8			encap_hdr_csum:1;
 	__u8			csum_valid:1;
 	__u8			csum_complete_sw:1;
-	/* 2/4 bit hole (depending on ndisc_nodetype presence) */
+	/* 1/3 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
-- 
1.7.11.7
