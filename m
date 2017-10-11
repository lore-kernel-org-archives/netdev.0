From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix tcp_unlink_write_queue()
Date: Wed, 11 Oct 2017 13:41:14 -0700 (PDT)
Message-ID: <20171011.134114.1377805651978859991.davem@davemloft.net>
References: <1507747717.31614.28.camel@edumazet-glaptop3.roam.corp.google.com>
        <20171011194355.n6mb4oe7qt76d6wh@yury-thinkpad>
        <1507753649.31614.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ynorov@caviumnetworks.com, netdev@vger.kernel.org,
        catalin.marinas@arm.com, weiwan@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36200 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757452AbdJKUlQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 16:41:16 -0400
In-Reply-To: <1507753649.31614.36.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Oct 2017 13:27:29 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Yury reported crash with this signature :
> 
> [  554.034021] [<ffff80003ccd5a58>] 0xffff80003ccd5a58
> [  554.034156] [<ffff00000888fd34>] skb_release_all+0x14/0x30
> [  554.034288] [<ffff00000888fd64>] __kfree_skb+0x14/0x28
> [  554.034409] [<ffff0000088ece6c>] tcp_sendmsg_locked+0x4dc/0xcc8
> [  554.034541] [<ffff0000088ed68c>] tcp_sendmsg+0x34/0x58
> [  554.034659] [<ffff000008919fd4>] inet_sendmsg+0x2c/0xf8
> [  554.034783] [<ffff0000088842e8>] sock_sendmsg+0x18/0x30
> [  554.034928] [<ffff0000088861fc>] SyS_sendto+0x84/0xf8
> 
> Problem is that skb->destructor contains garbage, and this is
> because I accidentally removed tcp_skb_tsorted_anchor_cleanup()
> from tcp_unlink_write_queue()
> 
> This would trigger with a write(fd, <invalid_memory>, len) attempt,
> and we will add to packetdrill this capability to avoid future
> regressions.
> 
> Fixes: 75c119afe14f ("tcp: implement rb-tree based retransmit queue")
> Reported-by: Yury Norov <ynorov@caviumnetworks.com>
> Tested-by: Yury Norov <ynorov@caviumnetworks.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
