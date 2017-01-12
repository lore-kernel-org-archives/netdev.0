From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: Fix kernel panic at security_sock_rcv_skb
Date: Thu, 12 Jan 2017 17:33:38 +0100
Message-ID: <9e6817a0-65b3-ed16-4616-f8e55aee09c4@hartkopp.net>
References: <1484202799-7287-1-git-send-email-shuo.a.liu@intel.com>
 <0e458012-e97b-298d-296e-ed25e35689a0@hartkopp.net>
 <1484226099.15816.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        linux-kernel@vger.kernel.org, yanmin_zhang@linux.intel.com,
        shuox.liu@gmail.com, Zhang Yanmin <yanmin.zhang@intel.com>,
        "He, Bo" <bo.he@intel.com>, Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:CAN NETWORK LAYER" <linux-can@vger.kernel.org>,
        "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Liu ShuoX <shuo.a.liu@intel.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1484226099.15816.25.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/12/2017 02:01 PM, Eric Dumazet wrote:
> On Thu, 2017-01-12 at 09:22 +0100, Oliver Hartkopp wrote:

>> But my main concern is:
>>
>> The reason why can_rx_delete_receiver() was introduced was the need to
>> remove a huge number of receivers with can_rx_unregister().
>>
>> When you call synchronize_rcu() after each receiver removal this would
>> potentially lead to a big performance issue when e.g. closing CAN_RAW
>> sockets with a high number of receivers.
>>
>> So the idea was to remove/unlink the receiver hlist_del_rcu(&r->list)
>> and also kmem_cache_free(rcv_cache, r) by some rcu mechanism - so that
>> all elements are cleaned up by rcu at a later point.
>>
>> Is it possible that the problems emerge due to hlist_del_rcu(&r->list)
>> and you accidently fix it with your introduced synchronize_rcu()?
>
> I agree this patch does not fix the root cause.
>
> The main problem seems that the sockets themselves are not RCU
> protected.
>
> If CAN uses RCU for delivery, then sockets should be freed only after
> one RCU grace period.
>
> On recent kernels, following patch could help :
>

Thanks Eric!

@Liu ShuoX: Can you check if Eric's suggestion fixes the issue in your 
setup?

Best regards,
Oliver
