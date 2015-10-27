From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: Re: [PATCH net-next V17 2/3] Check for vlan ethernet types for 8021.q
 or 802.1ad
Date: Tue, 27 Oct 2015 08:04:44 -0400
Message-ID: <562F685C.2000806@gmail.com>
References: <1445818286-4870-1-git-send-email-thomasfherbert@gmail.com>
 <1445818286-4870-3-git-send-email-thomasfherbert@gmail.com>
 <CAMu38xJ4UhALjFn05emEZSA0pBHtqsA13YyR7N2J0VeytO6sUw@mail.gmail.com>
Reply-To: thomasfherbert@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, therbert@redhat.com,
	dev@openvswitch.org
To: Albino B Neto <bino@bino.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:34291 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847AbbJ0MEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 08:04:47 -0400
Received: by ykdr3 with SMTP id r3so215198679ykd.1
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 05:04:46 -0700 (PDT)
In-Reply-To: <CAMu38xJ4UhALjFn05emEZSA0pBHtqsA13YyR7N2J0VeytO6sUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/15 8:14 AM, Albino B Neto wrote:
> 2015-10-25 22:11 GMT-02:00 Thomas F Herbert <thomasfherbert@gmail.com>:
>> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
>> ---
>>   include/linux/if_vlan.h | 16 ++++++++++++++++
>>   1 file changed, 16 insertions(+)
>>
>> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>> index 67ce5bd..d2494b5 100644
>> --- a/include/linux/if_vlan.h
>> +++ b/include/linux/if_vlan.h
>> @@ -627,6 +627,22 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
>>
>>          return features;
>>   }
>> +/**
>> + * eth_type_vlan - check for valid vlan ether type.
>> + * @ethertype: ether type to check
>> + *
>> + * Returns true if the ether type is a vlan ether type.
>> + */
>> +static inline bool eth_type_vlan(__be16 ethertype)
>> +{
>> +       switch (ethertype) {
>> +       case htons(ETH_P_8021Q):
>> +       case htons(ETH_P_8021AD):
>> +               return true;
>> +       default:
>> +               return false;
>> +       }
>> +}
>>
>>   /**
>>    * compare_vlan_header - Compare two vlan headers
> Description ?
This patch simplifies the code for openvswitch and potential other vlan 
code and drivers. There are at least two valid ether types for vlans and 
this code simplifies the openvswitch kernel module by simplifying code 
that checks for the presence of vlans. Do you want me to annotate the 
commit with additional description?
>
>     Albino
