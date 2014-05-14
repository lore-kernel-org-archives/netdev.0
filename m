From: =?UTF-8?B?5b6Q5rC45YGl?= <xuyongjiande@gmail.com>
Subject: Re: [E1000-devel] [PATCH] e1000: remove the check: skb->len<=0
Date: Wed, 14 May 2014 09:25:21 +0800
Message-ID: <CABVvea3GLVqwg7xMG9KhMfqvLxLQ8cE1NDeHXMxoA2+ZG06w4w@mail.gmail.com>
References: <1399957629-13536-1-git-send-email-xuyongjiande@gmail.com> <D38E8E86660E514AB505863C19C9287C73FBD0FE@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:48339 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbaENBZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 21:25:42 -0400
In-Reply-To: <D38E8E86660E514AB505863C19C9287C73FBD0FE@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check is not right, it should be "(int)(skb->len) <= 0", or we
just remove this check if "skb->len will never be negative or 0".

2014-05-13 22:57 GMT+08:00 Ronciak, John <john.ronciak@intel.com>:
>> -----Original Message-----
>> From: xuyongjiande@gmail.com [mailto:xuyongjiande@gmail.com]
>> Sent: Monday, May 12, 2014 10:07 PM
>> To: eric.dumazet@gmail.com
>> Cc: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org; Yongjian Xu
>> Subject: [E1000-devel] [PATCH] e1000: remove the check: skb->len<=0
>>
>> From: Yongjian Xu <xuyongjiande@gmail.com>
>>
>> There is no case skb->len would be 0 or 'negative'.
>> Remove the check.
>>
>> Signed-off-by: Yongjian Xu <xuyongjiande@gmail.com>
>> ---
>>  drivers/net/ethernet/intel/e1000/e1000_main.c | 5 -----
>>  1 file changed, 5 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c
>> b/drivers/net/ethernet/intel/e1000/e1000_main.c
>> index 27058df..660971f 100644
>> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
>> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
>> @@ -3105,11 +3105,6 @@ static netdev_tx_t e1000_xmit_frame(struct
>> sk_buff *skb,
>>        */
>>       tx_ring = adapter->tx_ring;
>>
>> -     if (unlikely(skb->len <= 0)) {
>> -             dev_kfree_skb_any(skb);
>> -             return NETDEV_TX_OK;
>> -     }
>> -
>>       /* On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
>>        * packets may get corrupted during padding by HW.
>>        * To WA this issue, pad all small packets manually.
>> --
>> 1.9.1
> What is the exact problem that this is fixing?  Did you have a test case that showed a problem with it?
>
> Cheers,
> John
>
>
