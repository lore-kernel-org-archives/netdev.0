From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH net-next 3/3] cxgb4: report GRO stats with ethtool -S
Date: Tue, 11 May 2010 01:45:36 -0700
Message-ID: <4BE91930.5040109@chelsio.com>
References: <1273543089-10938-1-git-send-email-dm@chelsio.com> <1273543089-10938-2-git-send-email-dm@chelsio.com> <1273543089-10938-3-git-send-email-dm@chelsio.com> <4BE8C8CD.1000200@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29481 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317Ab0EKIpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 04:45:41 -0400
In-Reply-To: <4BE8C8CD.1000200@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> On 05/10/2010 06:58 PM, Dimitris Michailidis wrote:
>> Signed-off-by: Dimitris Michailidis<dm@chelsio.com>
> 
> One of these is on-wire packets?  If so, maybe use the same
> string as Intel ixgbe uses:
> 
> rx_pkts_nic  # Pkts received by NIC from wire.
> rx_bytes_nic # Bytes received by NIC from wire.
> tx_pkts_nic  # Pkts transmitted to wire by NIC.
> tx_bytes_nic # Bytes transmitted to wire by NIC.

The two stats I'm adding don't correspond to any of the 4 above.  One is the 
superpackets coming out of GRO, the other is packets merged by GRO to create 
the superpackets.

> 
> Thanks,
> Ben
> 
> 
> 
>> ---
>>   drivers/net/cxgb4/cxgb4_main.c |    6 ++++++
>>   1 files changed, 6 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/cxgb4/cxgb4_main.c 
>> b/drivers/net/cxgb4/cxgb4_main.c
>> index 80c3fc5..90d375b 100644
>> --- a/drivers/net/cxgb4/cxgb4_main.c
>> +++ b/drivers/net/cxgb4/cxgb4_main.c
>> @@ -859,6 +859,8 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
>>       "RxCsumGood         ",
>>       "VLANextractions    ",
>>       "VLANinsertions     ",
>> +    "GROpackets         ",
>> +    "GROmerged          ",
>>   };
>>
>>   static int get_sset_count(struct net_device *dev, int sset)
>> @@ -922,6 +924,8 @@ struct queue_port_stats {
>>       u64 rx_csum;
>>       u64 vlan_ex;
>>       u64 vlan_ins;
>> +    u64 gro_pkts;
>> +    u64 gro_merged;
>>   };
>>
>>   static void collect_sge_port_stats(const struct adapter *adap,
>> @@ -938,6 +942,8 @@ static void collect_sge_port_stats(const struct 
>> adapter *adap,
>>           s->rx_csum += rx->stats.rx_cso;
>>           s->vlan_ex += rx->stats.vlan_ex;
>>           s->vlan_ins += tx->vlan_ins;
>> +        s->gro_pkts += rx->stats.lro_pkts;
>> +        s->gro_merged += rx->stats.lro_merged;
>>       }
>>   }
>>
> 
> 

