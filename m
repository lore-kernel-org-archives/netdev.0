From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 19/20] net: plip: slight optimization of addr
 compare
Date: Sat, 28 Dec 2013 13:05:49 +0800
Message-ID: <52BE5C2D.1030602@huawei.com>
References: <52BD22ED.4030302@huawei.com> <1388159283.12212.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388159283.12212.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/12/27 23:48, Eric Dumazet wrote:
> On Fri, 2013-12-27 at 14:49 +0800, Ding Tianhong wrote:
>> Use possibly more efficient ether_addr_equal
>> to instead of memcmp.
>>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>  drivers/net/plip/plip.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
>> index 7b4ff35..26614df 100644
>> --- a/drivers/net/plip/plip.c
>> +++ b/drivers/net/plip/plip.c
>> @@ -549,7 +549,7 @@ static __be16 plip_type_trans(struct sk_buff *skb, struct net_device *dev)
>>  
>>  	if(*eth->h_dest&1)
>>  	{
>> -		if(memcmp(eth->h_dest,dev->broadcast, ETH_ALEN)==0)
>> +		if(ether_addr_equal(eth->h_dest, dev->broadcast))
>>  			skb->pkt_type=PACKET_BROADCAST;
>>  		else
>>  			skb->pkt_type=PACKET_MULTICAST;
> 
> What about :
> 
>         if (is_multicast_ether_addr(eth->h_dest)) {
>                 if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
>                         skb->pkt_type = PACKET_BROADCAST;
>                 else
>                         skb->pkt_type = PACKET_MULTICAST;
>         }
> 
> 
> 
more better, thanks.

Regards
Ding

> 
> 
