From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 8/8 RFC v2] macvtap: Add support to get
 MAC/VLAN filter rtnl link operations
Date: Fri, 28 Oct 2011 11:24:19 -0700
Message-ID: <CAD04163.382EE%roprabhu@cisco.com>
References: <20111024055633.GC24528@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <sri@us.ibm.com>,
	<dragos.tatulea@gmail.com>, <arnd@arndb.de>, <kvm@vger.kernel.org>,
	<davem@davemloft.net>, <mchan@broadcom.com>, <dwang2@cisco.com>,
	<shemminger@vyatta.com>, <eric.dumazet@gmail.com>,
	<kaber@trash.net>, <benve@cisco.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:23366 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037Ab1J1SYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 14:24:21 -0400
In-Reply-To: <20111024055633.GC24528@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On 10/23/11 10:56 PM, "Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Tue, Oct 18, 2011 at 11:26:36PM -0700, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roprabhu@cisco.com>
>> 
>> This patch adds support to get MAC and VLAN filter rtnl_link_ops
>> on a macvtap interface. It adds support for get_rx_addr_filter_size,
>> get_rx_vlan_filter_size, fill_rx_addr_filter and fill_rx_vlan_filter
>> rtnl link operations. Calls equivalent macvlan operations.
>> 
>> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
>> Signed-off-by: Christian Benvenuti <benve@cisco.com>
>> Signed-off-by: David Wang <dwang2@cisco.com>
>> ---
>>  drivers/net/macvtap.c |   27 +++++++++++++++++++++++++++
>>  1 files changed, 27 insertions(+), 0 deletions(-)
>> 
>> 
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 8a2cb59..9b40de7 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -285,6 +285,29 @@ static int macvtap_set_rx_vlan_filter(struct net_device
>> *dev,
>> return macvlan_set_rx_vlan_filter(dev, tb);
>>  }
>>  
>> +static int macvtap_fill_rx_addr_filter(struct sk_buff *skb,
>> + const struct net_device *dev)
>> +{
>> + return macvlan_fill_rx_addr_filter(skb, dev);
>> +}
>> +
>> +static int macvtap_fill_rx_vlan_filter(struct sk_buff *skb,
>> + const struct net_device *dev)
>> +{
>> + return macvlan_fill_rx_vlan_filter(skb, dev);
>> +}
>> +
>> +static size_t macvtap_get_rx_addr_filter_size(const struct net_device *dev)
>> +{
>> + return macvlan_get_rx_addr_filter_size(dev);
>> +}
>> +
>> +static size_t macvtap_get_rx_vlan_filter_size(const struct net_device *dev)
>> +{
>> + return macvlan_get_rx_vlan_filter_size(dev);
>> +}
> 
> So why do we need the above wrappers? Can't use macvlanXXX directly?
> 

I had followed the existing macvtap rtnl_link_ops convention here.
It seems cleaner this way. You can define the macvtap ops static and
Call equivalent macvlan functions from it if required. It  also gives you
flexibility in adding any macvtap specific stuff before or after you call
the macvlan equivalent function (like some of the macvtap rtnl link ops
already do today)

In any case this part and the below empty line error goes away in the new
version.

Thanks,
Roopa


>> +
>> +
> 
> don't add double emoty lines pls.
> 
>>  static int macvtap_newlink(struct net *src_net,
>>   struct net_device *dev,
>>   struct nlattr *tb[],
>> @@ -335,6 +358,10 @@ static struct rtnl_link_ops macvtap_link_ops
>> __read_mostly = {
>> .dellink   = macvtap_dellink,
>> .set_rx_addr_filter  = macvtap_set_rx_addr_filter,
>> .set_rx_vlan_filter  = macvtap_set_rx_vlan_filter,
>> + .get_rx_addr_filter_size = macvtap_get_rx_addr_filter_size,
>> + .get_rx_vlan_filter_size = macvtap_get_rx_vlan_filter_size,
>> + .fill_rx_addr_filter  = macvtap_fill_rx_addr_filter,
>> + .fill_rx_vlan_filter  = macvtap_fill_rx_vlan_filter,
>>  };
>>  
>>  
