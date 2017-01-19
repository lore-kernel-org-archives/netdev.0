From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: cls_flower: reduce fl_change stack
 size
Date: Thu, 19 Jan 2017 11:23:07 -0500 (EST)
Message-ID: <20170119.112307.1679144601793219397.davem@davemloft.net>
References: <20170119094551.2780983-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, jiri@mellanox.com, hadarh@mellanox.com,
        amir@vadai.me, paulb@mellanox.com, ogerlitz@mellanox.com,
        simon.horman@netronome.com, roid@mellanox.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170119094551.2780983-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 19 Jan 2017 10:45:31 +0100

> The new ARP support has pushed the stack size over the edge on ARM,
> as there are two large objects on the stack in this function (mask
> and tb) and both have now grown a bit more:
> 
> net/sched/cls_flower.c: In function 'fl_change':
> net/sched/cls_flower.c:928:1: error: the frame size of 1072 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
> 
> We can solve this by dynamically allocating one or both of them.
> I first tried to do it just for the mask, but that only saved
> 152 bytes on ARM, while this version just does it for the 'tb'
> array, bringing the stack size back down to 664 bytes.
> 
> Fixes: 99d31326cbe6 ("net/sched: cls_flower: Support matching on ARP")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
