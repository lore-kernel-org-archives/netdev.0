From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v3 13/19] media: dvb_core: slight optimization of addr
 compare
Date: Wed, 8 Jan 2014 09:07:41 +0800
Message-ID: <52CCA4DD.40406@huawei.com>
References: <52BA5113.7070908@huawei.com> <52BABA23.2040709@cogentembedded.com> <52BC0E56.80003@huawei.com> <20140107115438.02c7424e@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<linux-media@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Mauro Carvalho Chehab <m.chehab@samsung.com>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <20140107115438.02c7424e@samsung.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/1/7 21:54, Mauro Carvalho Chehab wrote:
> Em Thu, 26 Dec 2013 19:09:10 +0800
> Ding Tianhong <dingtianhong@huawei.com> escreveu:
> 
>> On 2013/12/25 18:57, Sergei Shtylyov wrote:
>>> Hello.
>>>
>>> On 25-12-2013 7:29, Ding Tianhong wrote:
>>>
>>>> Use possibly more efficient ether_addr_equal
>>>> instead of memcmp.
>>>
>>>> Cc: Mauro Carvalho Chehab <m.chehab@samsung.com>
>>>> Cc: linux-media@vger.kernel.org
>>>> Cc: linux-kernel@vger.kernel.org
>>>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>>> ---
>>>>   drivers/media/dvb-core/dvb_net.c | 8 ++++----
>>>>   1 file changed, 4 insertions(+), 4 deletions(-)
>>>
>>>> diff --git a/drivers/media/dvb-core/dvb_net.c b/drivers/media/dvb-core/dvb_net.c
>>>> index f91c80c..3dfc33b 100644
>>>> --- a/drivers/media/dvb-core/dvb_net.c
>>>> +++ b/drivers/media/dvb-core/dvb_net.c
>>>> @@ -179,7 +179,7 @@ static __be16 dvb_net_eth_type_trans(struct sk_buff *skb,
>>>>       eth = eth_hdr(skb);
>>>>
>>>>       if (*eth->h_dest & 1) {
>>>> -        if(memcmp(eth->h_dest,dev->broadcast, ETH_ALEN)==0)
>>>> +        if(ether_addr_equal(eth->h_dest,dev->broadcast))
>>>
>>>    There should be space after comma.
>>>
>>>> @@ -674,11 +674,11 @@ static void dvb_net_ule( struct net_device *dev, const u8 *buf, size_t buf_len )
>>>>                       if (priv->rx_mode != RX_MODE_PROMISC) {
>>>>                           if (priv->ule_skb->data[0] & 0x01) {
>>>>                               /* multicast or broadcast */
>>>> -                            if (memcmp(priv->ule_skb->data, bc_addr, ETH_ALEN)) {
>>>> +                            if (!ether_addr_equal(priv->ule_skb->data, bc_addr)) {
>>>>                                   /* multicast */
>>>>                                   if (priv->rx_mode == RX_MODE_MULTI) {
>>>>                                       int i;
>>>> -                                    for(i = 0; i < priv->multi_num && memcmp(priv->ule_skb->data, priv->multi_macs[i], ETH_ALEN); i++)
>>>> +                                    for(i = 0; i < priv->multi_num && !ether_addr_equal(priv->ule_skb->data, priv->multi_macs[i]); i++)
>>>
>>>    Shouldn't this line be broken?
>>>
>>
>> ok, thanks.
> 
> Also, since you're touching on those lines, could you please add an space
> after 'if' (on the first hunk) and after 'for' (on the second one)?
> 

Ok, thanks

Regards
Ding

>>
>> Regards
>>>>                                           ;
>>>>                                       if (i == priv->multi_num)
>>>>                                           drop = 1;
>>>
>>> WBR, Sergei
>>>
>>>
>>>
>>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-media" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> Thanks,
> Mauro
> 
> .
> 
