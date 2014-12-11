From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/4] netdev: introduce new NETIF_F_HW_NETFUNC_OFFLOAD
 feature flag for switch device offloads
Date: Wed, 10 Dec 2014 20:31:12 -0800
Message-ID: <54891E10.2040400@cumulusnetworks.com>
References: <1418202320-19491-2-git-send-email-roopa@cumulusnetworks.com> <20141210093150.GA1863@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, vyasevic@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:41000 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaLKEbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 23:31:18 -0500
In-Reply-To: <20141210093150.GA1863@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/14, 1:31 AM, Jiri Pirko wrote:
> Wed, Dec 10, 2014 at 10:05:17AM CET, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This is a high level feature flag for all switch asic offloads
>>
>> switch drivers set this flag on switch ports. Logical devices like
>> bridge, bonds, vxlans can inherit this flag from their slaves/ports.
>
> Interesting thing is that you are talking about "switch" (mentioned 3
> times on 3 lines), yet the name of bit is "NETFUNC_OFFLOAD". I'm sorry,
> I might be missing some obvious facts but "netfunc" seems ambiguous
> to me.
scotts and your series and mine too is being introduced for switch asics 
right now.
And we are all only targeting l2 today. But, Keeping future in mind, the 
names we choose today
should be applicable for all other features and also other similar devices.
Even the 'switch' in the api names is making it not fit well in some cases.

I am not hung up on 'network function', if there are other suggestions I 
will be happy to take.

Thanks,
Roopa


>
>
>> The patch also adds the flag to NETIF_F_ONE_FOR_ALL, so that it gets
>> propagated to the upperdevices (bridges and bonds).
>>
>> (In case you did not notice, I am trying a new name NETIF_F_HW_NETFUNC_OFFLOAD for the flag ;)
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>> include/linux/netdev_features.h |    5 ++++-
>> 1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
>> index 8e30685..8ab175b 100644
>> --- a/include/linux/netdev_features.h
>> +++ b/include/linux/netdev_features.h
>> @@ -66,6 +66,7 @@ enum {
>> 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
>> 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
>> 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
>> +	NETIF_F_HW_NETFUNC_OFFLOAD_BIT,  /* HW switch offload */
>>
>> 	/*
>> 	 * Add your fresh new feature above and remember to update
>> @@ -124,6 +125,7 @@ enum {
>> #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
>> #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
>> #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
>> +#define NETIF_F_HW_NETFUNC_OFFLOAD	__NETIF_F(HW_NETFUNC_OFFLOAD)
>>
>> /* Features valid for ethtool to change */
>> /* = all defined minus driver/device-class-related */
>> @@ -159,7 +161,8 @@ enum {
>>   */
>> #define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST | \
>> 				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
>> -				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED)
>> +				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED | \
>> +				 NETIF_F_HW_NETFUNC_OFFLOAD)
>> /*
>>   * If one device doesn't support one of these features, then disable it
>>   * for all in netdev_increment_features.
>> -- 
>> 1.7.10.4
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
