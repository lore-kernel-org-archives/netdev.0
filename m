From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] vlan: remove one synchronize_net() call
Date: Mon, 09 May 2011 20:26:56 +0200
Message-ID: <4DC831F0.7010904@trash.net>
References: <1304948155.3342.32.camel@edumazet-laptop> <1304952044.3342.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Jesse Gross <jesse@nicira.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57661 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144Ab1EIS06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 14:26:58 -0400
In-Reply-To: <1304952044.3342.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 09.05.2011 16:40, schrieb Eric Dumazet:
> At VLAN dismantle phase, unregister_vlan_dev() makes one
> synchronize_net() call after vlan_group_set_device(grp, vlan_id, NULL=
).
>=20
> This call can be safely removed because we are calling
> unregister_netdevice_queue() to queue device for deletion, and this
> process needs at least one rcu grace period to complete.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Ben Greear <greearb@candelatech.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Jesse Gross <jesse@nicira.com>
> Cc: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  include/linux/if_vlan.h |    1 -
>  net/8021q/vlan.c        |   10 ++++------
>  2 files changed, 4 insertions(+), 7 deletions(-)
>=20
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 546d9d3..290bd8a 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -86,7 +86,6 @@ struct vlan_group {
>  					    * the vlan is attached to.
>  					    */
>  	unsigned int		nr_vlans;
> -	int			killall;

Looks good, thanks Eric.
