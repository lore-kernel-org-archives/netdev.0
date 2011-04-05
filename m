From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next-2.6] can: convert protocol handling to RCU
Date: Tue, 05 Apr 2011 19:52:35 +0200
Message-ID: <4D9B56E3.9080207@hartkopp.net>
References: <4D9A2844.2080304@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Urs Thuermann <urs@isnogud.escape.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:31054 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723Ab1DERwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 13:52:50 -0400
In-Reply-To: <4D9A2844.2080304@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.04.2011 22:21, Oliver Hartkopp wrote:
> This patch removes spin_locks at CAN socket creation time by using RCU.
> 


> @@ -143,22 +159,18 @@ static int can_create(struct net *net, struct socket *sock, int protocol,
>  		if (err && printk_ratelimit())
>  			printk(KERN_ERR "can: request_module "
>  			       "(can-proto-%d) failed.\n", protocol);
> +		else
> +			cp = can_try_module_get(protocol);
>  	}

Hm, i just discovered a tiny issue here as putting can_try_module_get() into
the 'else' path is not needed.

Will send a V2 in a few minutes.


Regards,
Oliver
