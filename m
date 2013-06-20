From: xiaoming gao <gxm.linux.kernel@gmail.com>
Subject: Re: [PATCH] net bridge: add null pointer check, fix panic
Date: Thu, 20 Jun 2013 15:00:58 +0800
Message-ID: <51C2A8AA.5010902@gmail.com>
References: <51C2710D.2060405@gmail.com> <51C2721B.9050603@gmail.com> <1371704129.3252.356.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, davem@davemloft.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371704129.3252.356.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet said, at 2013-6-20 12:55:
> On Thu, 2013-06-20 at 11:08 +0800, xiaoming gao wrote:
>> From: newtongao <newtongao@tencent.com>
>> Date: Wed, 19 Jun 2013 14:58:33 +0800
>> Subject: [PATCH] net bridge: add null pointer check,fix panic
>>
>> in kernel 3.0, br_port_get_rcu() may return NULL when network interface be deleting from bridge,
>> but in function br_handle_frame and br_handle_local_finish, the pointer didn't be checked before using,
>> so all br_port_get_rcu callers must do null check,or there occurs the null pointer panic.
>>
>> kernel 3.4 also has this bug,i have verified.
>> mainline kernel still did not  check br_port_get_rcu()'s NULL pointer, but i have not tested it yet.
> 
> Please check current version before sending a patch.
> 
> This was most probably fixed in commit 00cfec37484761a44
> ("net: add a synchronize_net() in netdev_rx_handler_unregister()")
> 
> Thanks
> 
> 
HI Eric
the problem is as follow:
br_del_if()-->del_nbp():

list_del_rcu(&p->list);
dev->priv_flags &= ~IFF_BRIDGE_PORT;

------>at this point, the nic be deleting still have rx_handler , so , may in br_handle_frame()
------>br_port_exists() will return false,so br_get_port_rcu() will return NULL
------>so in br_handle_frame , there will be a null panic.

netdev_rx_handler_unregister(dev);
synchronize_net();


i have checked commit 00cfec37484761a44, i think it didn't fix this bug..

thanks.
