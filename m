From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: BUG, 3.4.1, l2tp, kernel panic on rmmod
 =?UTF-8?Q?l=32tp=5Feth?=
Date: Thu, 07 Jun 2012 12:42:53 +0300
Message-ID: <66de011eba423f7b5eeb3c57e8430c5a@visp.net.lb>
References: <61a2ca9cc47a9a9a1c8a36738090dbf9@visp.net.lb>
 <1339060346.26966.106.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:57453 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab2FGJnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 05:43:06 -0400
In-Reply-To: <1339060346.26966.106.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not crashing anymore, after removing tunnel, i can unload module. 
Thanks.

On 2012-06-07 12:12, Eric Dumazet wrote:
> On Thu, 2012-06-07 at 11:31 +0300, Denys Fedoryshchenko wrote:
>> Hi
>>
>> Sorry for weird looking message, but this is how i got it over
>> netconsole
>>
>> If i have any tunnel+session configured and up and will do rmmod
>> l2tp_eth,
>> i will get panic, after my userspace program will fetch interfaces
>> information (over netlink).
>>
>> Probably it should not rmmod if there is tunnels configured?
>
> Sure, can you try the following patch ?
>
> diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
> index 443591d..185f12f 100644
> --- a/net/l2tp/l2tp_eth.c
> +++ b/net/l2tp/l2tp_eth.c
> @@ -162,6 +162,7 @@ static void l2tp_eth_delete(struct l2tp_session 
> *session)
>  		if (dev) {
>  			unregister_netdev(dev);
>  			spriv->dev = NULL;
> +			module_put(THIS_MODULE);
>  		}
>  	}
>  }
> @@ -249,6 +250,7 @@ static int l2tp_eth_create(struct net *net, u32
> tunnel_id, u32 session_id, u32 p
>  	if (rc < 0)
>  		goto out_del_dev;
>
> +	__module_get(THIS_MODULE);
>  	/* Must be done after register_netdev() */
>  	strlcpy(session->ifname, dev->name, IFNAMSIZ);
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
