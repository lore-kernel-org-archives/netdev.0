From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 3/8] mlxsw: spectrum_dpipe: Add IPv6 host table
 initial support
Date: Wed, 30 Aug 2017 11:36:13 -0600
Message-ID: <200b2c64-f252-c8cd-9e7c-e237bb7a8ce2@gmail.com>
References: <20170830120306.6128-1-jiri@resnulli.us>
 <20170830120306.6128-4-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:37213 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751929AbdH3RgP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 13:36:15 -0400
Received: by mail-pg0-f50.google.com with SMTP id 83so21673078pgb.4
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 10:36:15 -0700 (PDT)
In-Reply-To: <20170830120306.6128-4-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/30/17 6:03 AM, Jiri Pirko wrote:
> @@ -328,9 +329,21 @@ static int mlxsw_sp_dpipe_table_host_matches_dump(struct sk_buff *skb, int type)
>  	if (err)
>  		return err;
>  
> -	match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
> -	match.header = &devlink_dpipe_header_ipv4;
> -	match.field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
> +	switch (type) {
> +	case AF_INET:
> +		match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
> +		match.header = &devlink_dpipe_header_ipv4;
> +		match.field_id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP;
> +		break;
> +	case AF_INET6:
> +		match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
> +		match.header = &devlink_dpipe_header_ipv6;
> +		match.field_id = DEVLINK_DPIPE_FIELD_IPV6_DST_IP;
> +		break;
> +	default:
> +		WARN_ON(1);

Why a warn for dump request of an unsupported family?

> +		return -EINVAL;
> +	}
>  
>  	return devlink_dpipe_match_put(skb, &match);
>  }
> @@ -342,7 +355,7 @@ mlxsw_sp_dpipe_table_host4_matches_dump(void *priv, struct sk_buff *skb)
