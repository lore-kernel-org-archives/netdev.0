From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/8] mlxsw: spectrum_dpipe: Add IPv6 host table
 initial support
Date: Thu, 31 Aug 2017 09:17:58 +0200
Message-ID: <20170831071758.GA1973@nanopsycho>
References: <20170830120306.6128-1-jiri@resnulli.us>
 <20170830120306.6128-4-jiri@resnulli.us>
 <200b2c64-f252-c8cd-9e7c-e237bb7a8ce2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33584 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750907AbdHaHSA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 03:18:00 -0400
Received: by mail-wm0-f67.google.com with SMTP id m85so3481891wma.0
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 00:18:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200b2c64-f252-c8cd-9e7c-e237bb7a8ce2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 30, 2017 at 07:36:13PM CEST, dsahern@gmail.com wrote:
>On 8/30/17 6:03 AM, Jiri Pirko wrote:
>> @@ -328,9 +329,21 @@ static int mlxsw_sp_dpipe_table_host_matches_dump(struct sk_buff *skb, int type)
>>  	if (err)
>>  		return err;
>>  
>> -	match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
>> -	match.header = &devlink_dpipe_header_ipv4;
>> -	match.field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
>> +	switch (type) {
>> +	case AF_INET:
>> +		match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
>> +		match.header = &devlink_dpipe_header_ipv4;
>> +		match.field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
>> +		break;
>> +	case AF_INET6:
>> +		match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
>> +		match.header = &devlink_dpipe_header_ipv6;
>> +		match.field_id = DEVLINK_DPIPE_FIELD_IPV6_DST_IP;
>> +		break;
>> +	default:
>> +		WARN_ON(1);
>
>Why a warn for dump request of an unsupported family?

It's a handling of default case that should not happen unless there is a
bug in kernel.


>
>> +		return -EINVAL;
>> +	}
>>  
>>  	return devlink_dpipe_match_put(skb, &match);
>>  }
>> @@ -342,7 +355,7 @@ mlxsw_sp_dpipe_table_host4_matches_dump(void *priv, struct sk_buff *skb)
>
