From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] bridge: new attribute and flags to represent
 vlan info lists and ranges
Date: Wed, 31 Dec 2014 10:15:53 -0800
Message-ID: <54A43D59.1080304@cumulusnetworks.com>
References: <1420044533-16963-2-git-send-email-roopa@cumulusnetworks.com> <20141231174542.GA1922@hudson.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jeremiah Mahler <jmmahler@gmail.com>, netdev@vger.kernel.org,
	shemminger@vyatta.com, vyasevic@redhat.com, sfeldma@gmail.com,
	wkok@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:46141 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbaLaSPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 13:15:55 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so21604797pab.12
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 10:15:54 -0800 (PST)
In-Reply-To: <20141231174542.GA1922@hudson.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/31/14, 9:45 AM, Jeremiah Mahler wrote:
> Roopa,
>
> On Wed, Dec 31, 2014 at 08:48:52AM -0800, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds (as suggested by scott feldman),
>>          - new netlink attribute IFLA_BRIDGE_VLAN_INFO_LIST to represent
>>            vlan list
>>          - And bridge_vlan_info flags BRIDGE_VLAN_INFO_RANGE_START and
>>            BRIDGE_VLAN_INFO_RANGE_END to indicate start and end of vlan range
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>   include/uapi/linux/if_bridge.h |    4 ++++
>>   net/bridge/br_netlink.c        |    1 +
>>   2 files changed, 5 insertions(+)
>>
>> diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
>> index b03ee8f..fa468aa 100644
>> --- a/include/uapi/linux/if_bridge.h
>> +++ b/include/uapi/linux/if_bridge.h
>> @@ -112,12 +112,14 @@ struct __fdb_entry {
>>    *     [IFLA_BRIDGE_FLAGS]
>>    *     [IFLA_BRIDGE_MODE]
>>    *     [IFLA_BRIDGE_VLAN_INFO]
>> + *     [IFLA_BRIDGE_VLAN_INFO_LIST]
>>    * }
>>    */
>>   enum {
>>   	IFLA_BRIDGE_FLAGS,
>>   	IFLA_BRIDGE_MODE,
>>   	IFLA_BRIDGE_VLAN_INFO,
>> +	IFLA_BRIDGE_VLAN_INFO_LIST,
>>   	__IFLA_BRIDGE_MAX,
>>   };
>>   #define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
>> @@ -125,6 +127,8 @@ enum {
>>   #define BRIDGE_VLAN_INFO_MASTER	(1<<0)	/* Operate on Bridge device as well */
>>   #define BRIDGE_VLAN_INFO_PVID	(1<<1)	/* VLAN is PVID, ingress untagged */
>>   #define BRIDGE_VLAN_INFO_UNTAGGED	(1<<2)	/* VLAN egresses untagged */
>> +#define BRIDGE_VLAN_INFO_RANGE_START	(1<<3) /* VLAN is start of vlan range */
>> +#define BRIDGE_VLAN_INFO_RANGE_END	(1<<4) /* VLAN is end of vlan range */
>>   
> You add these here but you don't use them until the next patch.
> If they were wrong a bisect would point to the next patch.
>
> I would add them in the next patch where you start to use them.
I thought it was ok to declare it first and use them in the next patch. 
Only the other way around would be bad.
  I have submitted in a similar way before. If needed i will resubmit.




>>   struct bridge_vlan_info {
>>   	__u16 flags;
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index 9f5eb55..492ef6a 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -223,6 +223,7 @@ static const struct nla_policy ifla_br_policy[IFLA_MAX+1] = {
>>   	[IFLA_BRIDGE_MODE]	= { .type = NLA_U16 },
>>   	[IFLA_BRIDGE_VLAN_INFO]	= { .type = NLA_BINARY,
>>   				    .len = sizeof(struct bridge_vlan_info), },
>> +	[IFLA_BRIDGE_VLAN_INFO_LIST] = { .type = NLA_NESTED, },
>>   };
>>   
>>   static int br_afspec(struct net_bridge *br,
>> -- 
>> 1.7.10.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
