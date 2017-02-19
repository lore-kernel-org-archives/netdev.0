From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: sctp_transport_dst_check should check
 if transport pmtu is dst mtu
Date: Sun, 19 Feb 2017 18:19:55 -0500 (EST)
Message-ID: <20170219.181955.660651394406915269.davem@davemloft.net>
References: <7cbbbf479fddc8b516f87bc6258e775634e84dd6.1487320905.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54756 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbdBSXT5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 18:19:57 -0500
In-Reply-To: <7cbbbf479fddc8b516f87bc6258e775634e84dd6.1487320905.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 17 Feb 2017 16:41:45 +0800

> Now when sending a packet, sctp_transport_dst_check will check if dst
> is obsolete by calling ipv4/ip6_dst_check. But they return obsolete
> only when adding a new cache, after that when the cache's pmtu is
> updated again, it will not trigger transport->dst/pmtu's update.
> 
> It can be reproduced by reducing route's pmtu twice. At the 1st time
> client will add a new cache, and transport->pathmtu gets updated as
> sctp_transport_dst_check finds it's obsolete. But at the 2nd time,
> cache's mtu is updated, sctp client will never send out any packet,
> because transport->pmtu has no chance to update.
> 
> This patch is to fix this by also checking if transport pmtu is dst
> mtu in sctp_transport_dst_check, so that transport->pmtu can be
> updated on time.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
