From: Jianhua Xie <jianhua.xie@freescale.com>
Subject: Re: [PATCH net] bonding: enhance L2 hash helper with packet type
Date: Tue, 15 Jul 2014 15:48:09 +0800
Message-ID: <53C4DCB9.1050208@freescale.com>
References: <1405317926-27221-1-git-send-email-Jianhua.Xie@freescale.com> <20140714.190839.1595507738609644305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <j.vosburgh@gmail.com>,
	<vfalico@gmail.com>, <andy@greyhouse.net>,
	<Jiafei.Pan@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0140.outbound.protection.outlook.com ([207.46.163.140]:10858
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757882AbaGOHsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 03:48:46 -0400
In-Reply-To: <20140714.190839.1595507738609644305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/15/2014 10:08 AM, David Miller wrote:
> From: Xie Jianhua <Jianhua.Xie@freescale.com>
> Date: Mon, 14 Jul 2014 14:05:26 +0800
>
>> @@ -3002,7 +3002,7 @@ static inline u32 bond_eth_hash(struct sk_buff *skb)
>>   	struct ethhdr *data = (struct ethhdr *)skb->data;
>>   
>>   	if (skb_headlen(skb) >= offsetof(struct ethhdr, h_proto))
>> -		return data->h_dest[5] ^ data->h_source[5];
>> +		return data->h_dest[5] ^ data->h_source[5] ^ data->h_proto;
>>   
>>   	return 0;
>>   }
> About the headlen check, I don't like the idea that the hash depends upon
> whether we have a fully fragmented packet or not.
>
> Just use the appropriate interface, skb_header_pointer(), and recode this
> as:
>
> 	struct ethhdr *ep, _hdr;
>
> 	ep = skb_header_pointer(skb, 0, sizeof(_hdr), &_hdr);
> 	if (ep)
> 		return ep->h_dest[5] ^ ep->h_source[5] ^ ep->h_proto;
> 	return 0;
Many thanks, patch v2 is coming.

Best Regards,
Jianhua
