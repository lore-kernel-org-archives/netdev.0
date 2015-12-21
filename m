From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net] switchdev: bridge: Pass ageing time as clock_t instead
 of jiffies
Date: Mon, 21 Dec 2015 10:53:19 -0500
Message-ID: <5678206F.8050104@gmail.com>
References: <1450688161-4792-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, stephen@networkplumber.org,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:35764 "EHLO
	mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbbLUPx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 10:53:57 -0500
Received: by mail-vk0-f47.google.com with SMTP id a189so102800310vkh.2
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 07:53:57 -0800 (PST)
In-Reply-To: <1450688161-4792-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/15 3:56 AM, Jiri Pirko wrote:
> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index 5396ff08..12045de 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -39,7 +39,7 @@ void br_init_port(struct net_bridge_port *p)
>   	struct switchdev_attr attr = {
>   		.id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
>   		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP | SWITCHDEV_F_DEFER,
> -		.u.ageing_time = p->br->ageing_time,
> +		.u.ageing_time = jiffies_to_clock_t(p->br->ageing_time),
>   	};
>   	int err;


ageing_time is a u32; clock_t is a long.
