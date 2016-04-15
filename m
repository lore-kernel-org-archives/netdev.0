From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] vxlan: synchronously and race-free
 destruction of vxlan sockets
Date: Fri, 15 Apr 2016 16:36:44 -0400 (EDT)
Message-ID: <20160415.163644.1883719564658558438.davem@davemloft.net>
References: <1460148901-23740-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jbenc@redhat.com,
	marcelo.leitner@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbcDOUgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 16:36:46 -0400
In-Reply-To: <1460148901-23740-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri,  8 Apr 2016 22:55:01 +0200

> @@ -1053,7 +1052,9 @@ static void __vxlan_sock_release(struct vxlan_sock *vs)
>  	vxlan_notify_del_rx_port(vs);
>  	spin_unlock(&vn->sock_lock);
>  
> -	queue_work(vxlan_wq, &vs->del_work);
> +	synchronize_net();
> +	udp_tunnel_sock_release(vs->sock);
> +	kfree(vs);
>  }
>  
>  static void vxlan_sock_release(struct vxlan_dev *vxlan)

I just want to make sure you saw this change in net-next:

====================
commit ca065d0cf80fa547724440a8bf37f1e674d917c0
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri Apr 1 08:52:13 2016 -0700

    udp: no longer use SLAB_DESTROY_BY_RCU
====================

Does that effect your change?
