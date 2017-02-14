From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/8] gtp: switch from struct socket to
 struct sock for the GTP sockets
Date: Tue, 14 Feb 2017 12:48:15 -0500 (EST)
Message-ID: <20170214.124815.217549517821684819.davem@davemloft.net>
References: <20170213153624.14170-1-aschultz@tpip.net>
        <20170213153624.14170-3-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org, laforge@gnumonks.org,
        Lionel.Gauthier@eurecom.fr, osmocom-net-gprs@lists.osmocom.org,
        jonas@southpole.se
To: aschultz@tpip.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38262 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753057AbdBNRsR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 12:48:17 -0500
In-Reply-To: <20170213153624.14170-3-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Schultz <aschultz@tpip.net>
Date: Mon, 13 Feb 2017 16:36:18 +0100

> +	if (gtp->sk0) {
> +		udp_sk(gtp->sk0)->encap_type = 0;
> +		rcu_assign_sk_user_data(gtp->sk0, NULL);
> +		sock_put(gtp->sk0);
>  	}

This does "sock_put(NULL);" because you are assigning gtp->sk0 to
NULL before the sock_put() call.  So you are leaking the socket,
at best.

You need to load the socket pointer into a local variable in order
to do this correctly.
