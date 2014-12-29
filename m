From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 2/6] bridge: add new attribute IFLA_BRIDGE_VLAN_RANGE_INFO
 to represent vlan range
Date: Mon, 29 Dec 2014 14:10:58 -0800
Message-ID: <54A1D172.4070501@cumulusnetworks.com>
References: <1419887132-7084-3-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bCYJam86BYf9N8Z63g58njHrjpaH3sdHoSqJBxyFq=Y4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34153 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbaL2WK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 17:10:59 -0500
Received: by mail-pa0-f66.google.com with SMTP id rd3so14370766pab.5
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 14:10:59 -0800 (PST)
In-Reply-To: <CAE4R7bCYJam86BYf9N8Z63g58njHrjpaH3sdHoSqJBxyFq=Y4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/29/14, 1:52 PM, Scott Feldman wrote:
> On Mon, Dec 29, 2014 at 1:05 PM,  <roopa@cumulusnetworks.com> wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds new bridge netlink attribute IFLA_BRIDGE_VLAN_RANGE_INFO
>> to represent vlan range.
>>
>> Current IFLA_BRIDGE_VLAN_INFO attribute represents a single vlan and
>> does not scale well when the port has large number of vlans.
>>
>> IFLA_BRIDGE_VLAN_RANGE_INFO is similar to IFLA_BRIDGE_VLAN_INFO but helps
>> with packing consecutive vlans in a single attribute. Thus reducing the
>> size of the netlink msg during adds and also during dumps.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>> ---
>>   include/uapi/linux/if_bridge.h |    7 +++++++
>>   net/bridge/br_netlink.c        |    2 ++
>>   2 files changed, 9 insertions(+)
>>
>> diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
>> index b03ee8f..d41a346 100644
>> --- a/include/uapi/linux/if_bridge.h
>> +++ b/include/uapi/linux/if_bridge.h
>> @@ -118,6 +118,7 @@ enum {
>>          IFLA_BRIDGE_FLAGS,
>>          IFLA_BRIDGE_MODE,
>>          IFLA_BRIDGE_VLAN_INFO,
>> +       IFLA_BRIDGE_VLAN_RANGE_INFO,
>>          __IFLA_BRIDGE_MAX,
>>   };
>>   #define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
>> @@ -131,6 +132,12 @@ struct bridge_vlan_info {
>>          __u16 vid;
>>   };
>>
>> +struct bridge_vlan_range_info {
>> +       __u16 flags;
>> +       __u16 vid;
> vid_start or vid_begin to be consistent with vid_end?

ack..
>
>> +       __u16 vid_end;
>> +};
>> +
>>   /* Bridge multicast database attributes
>>    * [MDBA_MDB] = {
>>    *     [MDBA_MDB_ENTRY] = {
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index 75971b1..e7d1fc0 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -223,6 +223,8 @@ static const struct nla_policy ifla_br_policy[IFLA_MAX+1] = {
>>          [IFLA_BRIDGE_MODE]      = { .type = NLA_U16 },
>>          [IFLA_BRIDGE_VLAN_INFO] = { .type = NLA_BINARY,
>>                                      .len = sizeof(struct bridge_vlan_info), },
>> +       [IFLA_BRIDGE_VLAN_RANGE_INFO] = { .type = NLA_BINARY,
>> +                        .len = sizeof(struct bridge_vlan_range_info), },
> ifla_br_policy isn't used anymore from patch 1/6, so no need to add this.
>
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
