From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net/sched: cls_flower: reduce fl_change stack
 size
Date: Thu, 19 Jan 2017 10:55:06 +0100
Message-ID: <20170119095506.GA1801@nanopsycho.orion>
References: <20170119094551.2780983-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>, Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>,
        Roi Dayan <roid@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170119094551.2780983-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Jan 19, 2017 at 10:45:31AM CET, arnd@arndb.de wrote:
>The new ARP support has pushed the stack size over the edge on ARM,
>as there are two large objects on the stack in this function (mask
>and tb) and both have now grown a bit more:
>
>net/sched/cls_flower.c: In function 'fl_change':
>net/sched/cls_flower.c:928:1: error: the frame size of 1072 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
>
>We can solve this by dynamically allocating one or both of them.
>I first tried to do it just for the mask, but that only saved
>152 bytes on ARM, while this version just does it for the 'tb'
>array, bringing the stack size back down to 664 bytes.
>
>Fixes: 99d31326cbe6 ("net/sched: cls_flower: Support matching on ARP")
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Jiri Pirko <jiri@mellanox.com>
