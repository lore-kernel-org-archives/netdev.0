From: Ido Shamay <idos@dev.mellanox.co.il>
Subject: Re: [PATCH net] net/mlx4_en: mlx4_en_netpoll shouldn't call napi_schedule
 when port is down
Date: Mon, 20 Oct 2014 18:59:44 +0300
Message-ID: <54453170.7080909@dev.mellanox.co.il>
References: <1411988695-30547-1-git-send-email-amirv@mellanox.com> <20140929.134704.646626597842088240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: idos@mellanox.com, netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>, amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:46065 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbaJTP7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 11:59:49 -0400
Received: by mail-wi0-f172.google.com with SMTP id n3so7577983wiv.5
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 08:59:47 -0700 (PDT)
In-Reply-To: <20140929.134704.646626597842088240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/29/2014 8:47 PM, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Mon, 29 Sep 2014 14:04:55 +0300
>
>> From: Ido Shamay <idos@mellanox.com>
>>
>> mlx4_en_netpoll, which is mlx4_en ndo_poll_controller callback,
>> might be called when port is down, causing a napi_schedule when
>> napi->poll callback in NULL. mutex_trylock is needed to acquire
>> the port_state lock, since other threads may grab it and stop
>> the port while we are in napi scheduling. Using trylock since in atomic
>> context.
>>
>> Signed-off-by: Ido Shamay <idos@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>
> I don't think netpoll should 'variably succeed' on poll controller's
> ability to immediately take a trylock.
>
> You need to find a way to make this code always process the queues
> when it is called, the approach you are taking here is not a correct.
>
> If you've designed things in such a way that the locking here is
> difficult, that's unfortunate but you still have to make this
> function behave properly.

Sorry about that, aborting this commit since the problem was already 
fixed in commit 3484aac1, which added netif_device_detach to driver port 
stop flow and that made netconsole not to call ndo_poll_controller callback.

Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
