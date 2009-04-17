From: Saikiran Madugula <hummerbliss@gmail.com>
Subject: Re: [PATCH] Allow fragmentation of VLAN packets traversing a bridge.
Date: Fri, 17 Apr 2009 18:07:08 +0100
Message-ID: <49E8B73C.7080004@gmail.com>
References: <49E89E0D.5080000@gmail.com> <49E8A6DF.3040905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E8A6DF.3040905@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Saikiran Madugula wrote:
>> br_nf_dev_queue_xmit only checks for ETH_P_IP packets for fragmenting
>> but not
>> VLAN packets. This results in dropping of large VLAN packets. This can be
>> observed when connection tracking is enabled. Connection tracking
>> re-assembles
>> fragmented packets, and these have to be re-fragmented when
>> transmitting out.
>>
>> Signed-off-by: Saikiran Madugula <hummerbliss@gmail.com>
>> ---
>>  net/bridge/br_netfilter.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
>> index 3953ac4..941f702 100644
>> --- a/net/bridge/br_netfilter.c
>> +++ b/net/bridge/br_netfilter.c
>> @@ -790,7 +790,7 @@ static unsigned int br_nf_local_out(unsigned int
>> hook, struct sk_buff *skb,
>>  
>>  static int br_nf_dev_queue_xmit(struct sk_buff *skb)
>>  {
>> -    if (skb->protocol == htons(ETH_P_IP) &&
>> +    if ((skb->protocol == htons(ETH_P_IP) || IS_VLAN_IP(skb)) &&
>>          skb->len > skb->dev->mtu &&
>>          !skb_is_gso(skb))
>>          return ip_fragment(skb, br_dev_queue_push_xmit);
> 
> Please add an additional check for skb->nfct != NULL to make sure
> that this only refragments packets defragmented by conntrack.

Thanks for the feedback, skb->nfct is present only if CONFIG_NF_CONNTRACK or
CONFIG_NF_CONNTRACK_MODULE is defined. Was wondering if the entire check before
ip_fragment is necessary if NF_CONNTRACK is not defined. If not, I will post
updated patch as per your suggestion.
