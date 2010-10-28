From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2.6.36/stable v2] vlan: Fix crash when hwaccel rx pkt
 for non-existant vlan.
Date: Wed, 27 Oct 2010 17:15:53 -0700
Message-ID: <4CC8C0B9.6090209@candelatech.com>
References: <1288112797-21550-1-git-send-email-greearb@candelatech.com> <AANLkTi=EHVBSNNmsts4xTVZ2DGTBD92mHnpP0e5ZYEx1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51919 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757642Ab0J1AP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 20:15:59 -0400
In-Reply-To: <AANLkTi=EHVBSNNmsts4xTVZ2DGTBD92mHnpP0e5ZYEx1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2010 05:11 PM, Jesse Gross wrote:
> On Tue, Oct 26, 2010 at 10:06 AM, Ben Greear<greearb@candelatech.com>  wrote:
>> The vlan_hwaccel_do_receive code expected skb->dev to always
>> be a vlan device, but if the NIC was promisc, and the VLAN
>> for a particular VID was not configured, then this method
>> could receive a packet where skb->dev was NOT a vlan
>> device.  This caused access of bad memory and a crash.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>> ---
>> v1 ->  v2:  Simplify patch..no need for setting pkt-type, etc.
>>
>> :100644 100644 0eb96f7... 0687b6c... M  net/8021q/vlan_core.c
>> :100644 100644 660dd41... 5dc45b9... M  net/core/dev.c
>>   net/8021q/vlan_core.c |    3 +++
>>   net/core/dev.c        |    5 +++--
>>   2 files changed, 6 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>> index 0eb96f7..0687b6c 100644
>> --- a/net/8021q/vlan_core.c
>> +++ b/net/8021q/vlan_core.c
>> @@ -43,6 +43,9 @@ int vlan_hwaccel_do_receive(struct sk_buff *skb)
>>         struct net_device *dev = skb->dev;
>>         struct vlan_rx_stats     *rx_stats;
>>
>> +       if (!is_vlan_dev(dev))
>> +               return 0;
>> +
>>         skb->dev = vlan_dev_info(dev)->real_dev;
>>         netif_nit_deliver(skb);
>>
>
> What if we dropped any packet with a tag in skb->vlan_tci before it
> gets to the bridge hooks?  That would accomplish the original goal of
> getting packets to tcpdump while preventing them from making it to
> places where they aren't expected,  It will provide the same behavior
> as earlier kernels.

The VLAN code has changed a lot since I messed with it last, so
there very well may be better ways to fix this than what I came up
with.  Please propose a patch if you have a suggestion.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
