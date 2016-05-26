From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net 4/4] net/mlx4_en: get rid of private net_device_stats
Date: Thu, 26 May 2016 12:38:58 +0300
Message-ID: <6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
 <1464195039-5098-5-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33979 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147AbcEZJjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 05:39:02 -0400
Received: by mail-wm0-f66.google.com with SMTP id n129so3166983wmn.1
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 02:39:01 -0700 (PDT)
In-Reply-To: <1464195039-5098-5-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Thanks for the fix.

> We do not need to clear fields that are already 0.
Why is it always true that dev->stats is already 0 at the point ndo_open 
is called?
Is it true also in a flow of open -> stop -> open? I searched the kernel 
stack for this but couldn't find.
> @@ -1877,7 +1877,6 @@ static void mlx4_en_clear_stats(struct net_device *dev)
>   	if (mlx4_en_DUMP_ETH_STATS(mdev, priv->port, 1))
>   		en_dbg(HW, priv, "Failed dumping statistics\n");
>   
> -	memset(&priv->stats, 0, sizeof(priv->stats));
>   	memset(&priv->pstats, 0, sizeof(priv->pstats));
>   	memset(&priv->pkstats, 0, sizeof(priv->pkstats));
>   	memset(&priv->port_stats, 0, sizeof(priv->port_stats));
The role of this function is to clear the stats, no matter when and 
where it is called.
I am aware that clearing the stats structure might be redundant today, 
as the function is called only within mlx4_en_open, but we might want to 
call the function in other flows in the future.

Regards,
Tariq
