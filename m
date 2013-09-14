From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] bridge: fix NULL pointer deref of
 br_port_get_rcu
Date: Sat, 14 Sep 2013 11:47:59 -0700
Message-ID: <1379184479.24408.46.camel@edumazet-glaptop>
References: <1379169748-767-1-git-send-email-zhiguohong@tencent.com>
	 <1379169748-767-3-git-send-email-zhiguohong@tencent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, vyasevic@redhat.com,
	Hong Zhiguo <zhiguohong@tencent.com>
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35788 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756702Ab3INSsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Sep 2013 14:48:01 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so2528930pdj.26
        for <netdev@vger.kernel.org>; Sat, 14 Sep 2013 11:48:01 -0700 (PDT)
In-Reply-To: <1379169748-767-3-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-09-14 at 22:42 +0800, Hong Zhiguo wrote:
> From: Hong Zhiguo <zhiguohong@tencent.com>
> 
> The NULL deref happens when br_handle_frame is called between these
> 2 lines of del_nbp:
> 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
> 	/* --> br_handle_frame is called at this time */
> 	netdev_rx_handler_unregister(dev);
> 
> In br_handle_frame the return of br_port_get_rcu(dev) is dereferenced
> without check but br_port_get_rcu(dev) returns NULL if:
> 	!(dev->priv_flags & IFF_BRIDGE_PORT)
> 
> Eric Dumazet pointed out the testing of IFF_BRIDGE_PORT is not necessary
> here since we're in rcu_read_lock and we have synchronize_net() in
> netdev_rx_handler_unregister. So remove the testing of IFF_BRIDGE_PORT
> and by the previous patch, make sure br_port_get_rcu is called in
> bridging code.
> 
> Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
> ---
>  net/bridge/br_private.h | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Again this is suitable for net tree.

Thanks !
