From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: do metrics match when looking up and
 deleting a route
Date: Wed, 23 Aug 2017 20:38:00 -0700 (PDT)
Message-ID: <20170823.203800.2128849794896344817.davem@davemloft.net>
References: <63b0473e7248f4931d46c45ac64e63b07bea6eeb.1503454046.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58226 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdHXDiB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 23:38:01 -0400
In-Reply-To: <63b0473e7248f4931d46c45ac64e63b07bea6eeb.1503454046.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 23 Aug 2017 10:07:26 +0800

> Now when ipv4 route inserts a fib_info, it memcmp fib_metrics.
> It means ipv4 route identifies one route also with metrics.
> 
> But when removing a route, it tries to find the route without
> caring about the metrics. It will cause that the route with
> right metrics can't be removed.
> 
> Thomas noticed this issue when doing the testing:
> 
> 1. add:
>    # ip route append 192.168.7.0/24 dev v window 1000
>    # ip route append 192.168.7.0/24 dev v window 1001
>    # ip route append 192.168.7.0/24 dev v window 1002
>    # ip route append 192.168.7.0/24 dev v window 1003
> 2. delete:
>    # ip route delete 192.168.7.0/24 dev v window 1002
> 3. show:
>      192.168.7.0/24 proto boot scope link window 1001
>      192.168.7.0/24 proto boot scope link window 1002
>      192.168.7.0/24 proto boot scope link window 1003
> 
> The one with window 1002 wasn't deleted but the first one was.
> 
> This patch is to do metrics match when looking up and deleting
> one route.
> 
> Reported-by: Thomas Haller <thaller@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
