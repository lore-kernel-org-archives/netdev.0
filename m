From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next] can: fix build error without CONFIG_PROC_FS
Date: Thu, 27 Apr 2017 18:11:11 +0200
Message-ID: <499a8b67-8180-487b-9e7f-9ec0dc85adad@hartkopp.net>
References: <20170427142146.3107957-1-arnd@arndb.de>
 <937e9144-c06c-d265-29eb-a1c6f96b6f89@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Mario Kicherer <dev@kicherer.org>,
        Eric Dumazet <edumazet@google.com>, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
        Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <937e9144-c06c-d265-29eb-a1c6f96b6f89@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Arnd,

many thanks for your patch.

Btw

 >  static void canbcm_pernet_exit(struct net *net)
 >  {
 > +#ifdef CONFIG_PROC_FS
 >  	/* remove /proc/net/can-bcm directory */
 >  	if (IS_ENABLED(CONFIG_PROC_FS)) {
 >  		if (net->can.bcmproc_dir)
 >  			remove_proc_entry("can-bcm", net->proc_net);
 >  	}
 > +#endif
 >  }

"if (IS_ENABLED(CONFIG_PROC_FS))"

becomes obsolete too then ...

So I would suggest to take my patch to fix my fault ;-)

Best regards,
Oliver

On 04/27/2017 04:29 PM, Marc Kleine-Budde wrote:
> Hello Arnd,
>
> On 04/27/2017 04:21 PM, Arnd Bergmann wrote:
>> The procfs dir entry was added inside of an #ifdef, causing a build error
>> when we try to access it without CONFIG_PROC_FS set:
>>
>> net/can/bcm.c:1541:14: error: 'struct netns_can' has no member named 'bcmproc_dir'
>> net/can/bcm.c: In function 'bcm_connect':
>> net/can/bcm.c:1601:14: error: 'struct netns_can' has no member named 'bcmproc_dir'
>> net/can/bcm.c: In function 'canbcm_pernet_init':
>> net/can/bcm.c:1696:11: error: 'struct netns_can' has no member named 'bcmproc_dir'
>> net/can/bcm.c: In function 'canbcm_pernet_exit':
>> net/can/bcm.c:1707:15: error: 'struct netns_can' has no member named 'bcmproc_dir'
>>
>> This adds the same #ifdef around all users of the pointer. Alternatively
>> we could move the pointer outside of the #ifdef.
>>
>> Fixes: 384317ef4187 ("can: network namespace support for CAN_BCM protocol")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>
> A fix for this problem is part of the pull request I send to David
> earlier today:
>
>     https://www.mail-archive.com/netdev@vger.kernel.org/msg165764.html
>
> regards,
> Marc
>
