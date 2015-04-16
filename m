From: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 4/6] net: hip04: Don't free the tx skb when the
 buffer is not ready for xmit
Date: Thu, 16 Apr 2015 14:26:21 +0800
Message-ID: <552F560D.4070309@huawei.com>
References: <1429101008-9464-1-git-send-email-dingtianhong@huawei.com> <1429101008-9464-5-git-send-email-dingtianhong@huawei.com> <2218546.M1hzu1bzfh@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2218546.M1hzu1bzfh@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2015/4/15 22:19, Arnd Bergmann wrote:
> On Wednesday 15 April 2015 20:30:06 Ding Tianhong wrote:
>> @@ -489,6 +487,8 @@ static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>>  
>>         /* Ensure tx_head update visible to tx reclaim */
>>         smp_wmb();
>> +       count++;
>> +       priv->tx_head = TX_NEXT(tx_head);
>>  
>>
> 
> Something is wrong here, the comment does not match the code any more, because
> the smp_wmb() won't actually make the tx_head update visible.
> 
> 	Arnd
> 
Yes, the smp_wmb() could only make sure the tx buffer was ready to xmit.

> .
> 


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
