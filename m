From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH 3/3] gianfar: fix endianness for hardware timestamp
Date: Wed, 24 Feb 2016 19:14:27 +0900
Message-ID: <56CD8283.3090605@miraclelinux.com>
References: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
 <1456123773-1016-4-git-send-email-yangbo.lu@nxp.com>
 <20160222084801.GC2138@netboy>
 <HE1PR04MB0889C90C284F8C3B0F04DDA1F8A50@HE1PR04MB0889.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: Yangbo Lu <yangbo.lu@nxp.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34523 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044AbcBXKOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 05:14:30 -0500
Received: by mail-pf0-f175.google.com with SMTP id x65so10625603pfb.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 02:14:30 -0800 (PST)
In-Reply-To: <HE1PR04MB0889C90C284F8C3B0F04DDA1F8A50@HE1PR04MB0889.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Yangbo Lu wrote:
>> -----Original Message-----
>> From: Richard Cochran [mailto:richardcochran@gmail.com]
>> Sent: Monday, February 22, 2016 4:48 PM
>> To: Yangbo Lu
>> Cc: netdev@vger.kernel.org; Claudiu Manoil
>> Subject: Re: [PATCH 3/3] gianfar: fix endianness for hardware timestamp
>>
>> On Mon, Feb 22, 2016 at 02:49:33PM +0800, Yangbo Lu wrote:
>>> @@ -2708,6 +2708,7 @@ static void gfar_clean_tx_ring(struct
>> gfar_priv_tx_q *tx_queue)
>>>  			struct skb_shared_hwtstamps shhwtstamps;
>>>  			u64 *ns = (u64 *)(((uintptr_t)skb->data + 0x10) &
>>>  					  ~0x7UL);
>>> +			*ns = be64_to_cpu(*ns);
>>>
>>>  			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
>>>  			shhwtstamps.hwtstamp = ns_to_ktime(*ns);
>>
>> There is no point in modifying the buffer data in place.
>>
>> Instead, do this:
>>
>> 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
>> 			shhwtstamps.hwtstamp = ns_to_ktime(be64_to_cpu(*ns));
>>
>> or this:
>>
>> 			u64 ns, *ptr = (u64 *)(((uintptr_t)skb->data + 0x10) &
>> 					       ~0x7UL);
>> 			ns = be64_to_cpu(*ptr);
>>
>> 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
>> 			shhwtstamps.hwtstamp = ns_to_ktime(ns);
>>
> 
> [Lu Yangbo-B47093] I will modify codes according your suggestion.
> Thank you so much!

You may want to use PTR_ALIGN() and be64_to_cpup() here.

--yoshfuji

>  
>>> @@ -3037,6 +3038,7 @@ static void gfar_process_frame(struct net_device
>> *ndev, struct sk_buff *skb)
>>>  	if (priv->hwts_rx_en) {
>>>  		struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
>>>  		u64 *ns = (u64 *) skb->data;
>>> +		*ns = be64_to_cpu(*ns);
>>>
>>>  		memset(shhwtstamps, 0, sizeof(*shhwtstamps));
>>>  		shhwtstamps->hwtstamp = ns_to_ktime(*ns);
>>
>> Same here.
>>
>> Thanks,
>> Richard

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
