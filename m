From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 1/5] netdev: introduce new NETIF_F_HW_NETFUNC_OFFLOAD
 feature flag for switch device offloads
Date: Fri, 23 Jan 2015 07:48:28 -0800
Message-ID: <54C26D4C.9050407@cumulusnetworks.com>
References: <1421987606-10884-2-git-send-email-roopa@cumulusnetworks.com> <20150123094459.GA2065@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	vyasevic@redhat.com, ronen.arad@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net, shm@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:63533 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481AbbAWPs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 10:48:29 -0500
Received: by mail-pd0-f173.google.com with SMTP id fp1so9204234pdb.4
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 07:48:29 -0800 (PST)
In-Reply-To: <20150123094459.GA2065@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/15, 1:44 AM, Jiri Pirko wrote:
> Fri, Jan 23, 2015 at 05:33:22AM CET, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This is a high level feature flag for all switch asic offloads
>>
>> switch drivers set this flag on switch ports. Logical devices like
>> bridge, bonds, vxlans can inherit this flag from their slaves/ports.
>>
>> The patch also adds the flag to NETIF_F_ONE_FOR_ALL, so that it gets
>> propagated to the upperdevices (bridges and bonds).
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>> include/linux/netdev_features.h |    6 +++++-
>> 1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
>> index 8e30685..784a461 100644
>> --- a/include/linux/netdev_features.h
>> +++ b/include/linux/netdev_features.h
>> @@ -66,6 +66,7 @@ enum {
>> 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
>> 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
>> 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
>> +	NETIF_F_HW_NETFUNC_OFFLOAD_BIT,  /* HW switch offload */
> How about rather "HW_DATAPATH_OFFLOAD"? Feels more accurate. By the
> name, I still cannot understand what NETFUNC should mean.

It was supposed to mean 'network function offload'. sure, will consider 
HW_DATAPATH_OFFLOAD
or if anybody has other suggestions.

thanks.
>
>
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
>> @@ -159,7 +161,9 @@ enum {
>>   */
>> #define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST | \
>> 				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
>> -				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED)
>> +				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED | \
>> +				 NETIF_F_HW_NETFUNC_OFFLOAD)
>> +
>> /*
>>   * If one device doesn't support one of these features, then disable it
>>   * for all in netdev_increment_features.
>> -- 
>> 1.7.10.4
>>
