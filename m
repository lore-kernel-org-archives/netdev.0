From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 1/3] netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature
 flag for switch device offloads
Date: Fri, 05 Dec 2014 06:16:07 -0800
Message-ID: <5481BE27.6000505@cumulusnetworks.com>
References: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com> <20141205074127.GB1866@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, nhorman@tuxdriver.com,
	nicolas.dichtel@6wind.com, vyasevic@redhat.com,
	f.fainelli@gmail.com, buytenh@wantstofly.org, aviadr@mellanox.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:35668 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbaLEOQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 09:16:26 -0500
In-Reply-To: <20141205074127.GB1866@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/4/14, 11:41 PM, Jiri Pirko wrote:
> Fri, Dec 05, 2014 at 03:26:39AM CET, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This is a generic high level feature flag for all switch asic features today.
>>
>> switch drivers set this flag on switch ports. Logical devices like
>> bridge, bonds, vxlans can inherit this flag from their slaves/ports.
>
> Can you please elaborate on how exactly would this inheritance look
> like?

My thought there was, when a port with the hw offload flag is added to 
the bridge, the same flag gets set on the bridge. And, for any bridge 
attributes (not port attributes), this flag on the bridge can be used to 
offload those bridge attributes.
bridge attribute examples: IFLA_BR_FORWARD_DELAY, IFLA_BR_HELLO_TIME, 
IFLA_BR_MAX_AGE.
I don't think offloads for these are handled today. I was going to look 
at them as part of continued work on this.
The current patches only target bridge port attributes and the flag for 
this is already set by the port driver.

I believe netdev_update_features() takes care of the updating the flag 
on the bridge part. I plan to check on that.


>
>
>> I had to use SWITCH in the name to avoid ambiguity with other feature
>> flags. But, since i have been harping about not calling it 'switch',
>> I am welcome to any suggestions :)
>>
>> An alternative to using a feature flag is to use a IFF_HW_OFFLOAD
>> in net_device_flags.
>> ---
>> include/linux/netdev_features.h |    2 ++
>> 1 file changed, 2 insertions(+)
>>
>> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
>> index 8e30685..68db1de 100644
>> --- a/include/linux/netdev_features.h
>> +++ b/include/linux/netdev_features.h
>> @@ -66,6 +66,7 @@ enum {
>> 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
>> 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
>> 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
>> +	NETIF_F_HW_SWITCH_OFFLOAD_BIT,  /* HW switch offload */
>>
>> 	/*
>> 	 * Add your fresh new feature above and remember to update
>> @@ -124,6 +125,7 @@ enum {
>> #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
>> #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
>> #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
>> +#define NETIF_F_HW_SWITCH_OFFLOAD	__NETIF_F(HW_SWITCH_OFFLOAD)
>>
>> /* Features valid for ethtool to change */
>> /* = all defined minus driver/device-class-related */
>> -- 
>> 1.7.10.4
>>
