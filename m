From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Mon, 05 Jan 2015 16:45:50 -0800
Message-ID: <54AB303E.3000601@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20141231194544.31070.30335.stgit@nitbit.x32> <20150104111238.GD15305@casper.infradead.org> <54AADEFF.3090306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, jhs@mojatatu.com,
	simon.horman@netronome.com, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:48678 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbbAFAqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 19:46:08 -0500
Received: by mail-ob0-f169.google.com with SMTP id vb8so63636037obc.0
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 16:46:08 -0800 (PST)
In-Reply-To: <54AADEFF.3090306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>> +/**
>>> + * @struct net_flow_field_ref
>>> + * @brief uniquely identify field as header:field tuple
>>> + */
>>> +struct net_flow_field_ref {
>>> +    int instance;
>>> +    int header;
>>> +    int field;
>>> +    int mask_type;
>>> +    int type;
>>> +    union {    /* Are these all the required data types */
>>> +        __u8 value_u8;
>>> +        __u16 value_u16;
>>> +        __u32 value_u32;
>>> +        __u64 value_u64;
>>> +    };
>>> +    union {    /* Are these all the required data types */
>>> +        __u8 mask_u8;
>>> +        __u16 mask_u16;
>>> +        __u32 mask_u32;
>>> +        __u64 mask_u64;
>>> +    };
>>> +};
>>
>> Does it make sense to write this as follows?
>
> Yes. I'll make this update it helps make it clear value/mask pairs are
> needed.
>
>>
>> union {
>>          struct {
>>                  __u8 value_u8;
>>                  __u8 mask_u8;
>>          };
>>          struct {
>>                  __u16 value_u16;
>>                  __u16 mask_u16;
>>          };
>>          ...
>> };

Another thought is to pull this entirely out of the structure and hide
it from the UAPI so we can add more value/mask types as needed without
having to spin versions of net_flow_field_ref. On the other hand I've
been able to fit all my fields in these types so far and I can't think
of any additions we need at the moment.

>>
>>> +#define NET_FLOW_TABLE_EGRESS_ROOT 1
>>> +#define    NET_FLOW_TABLE_INGRESS_ROOT 2
>>
>> Tab/space mix.
>>
>

[...]


-- 
John Fastabend         Intel Corporation
