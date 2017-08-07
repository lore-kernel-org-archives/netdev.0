From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next v3 12/13] net: bridge: Remove FDB deletion
 through switchdev object
Date: Mon, 7 Aug 2017 12:31:11 +0200
Message-ID: <714f4be4-6828-5785-62d4-16b1b81fc7af@redhat.com>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
 <1502025351-41261-13-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, f.fainelli@gmail.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        Woojung.Huh@microchip.com, mlxsw@mellanox.com
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27453 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752766AbdHGKbO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Aug 2017 06:31:14 -0400
In-Reply-To: <1502025351-41261-13-git-send-email-arkadis@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6.8.2017 15:15, Arkadi Sharshevsky wrote:
> At this point no driver supports FDB add/del through switchdev object
> but rather via notification chain, thus, it is removed.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  net/bridge/br_fdb.c | 18 ------------------
>  1 file changed, 18 deletions(-)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index a5e4a73..a79b648 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -169,29 +169,11 @@ static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
>  	}
>  }
>  
> -static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
> -{
> -	struct switchdev_obj_port_fdb fdb = {
> -		.obj = {
> -			.orig_dev = f->dst->dev,
> -			.id = SWITCHDEV_OBJ_ID_PORT_FDB,
> -			.flags = SWITCHDEV_F_DEFER,
> -		},
> -		.vid = f->vlan_id,
> -	};
> -
> -	ether_addr_copy(fdb.addr, f->addr.addr);
> -	switchdev_port_obj_del(f->dst->dev, &fdb.obj);
> -}
> -
>  static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
>  {
>  	if (f->is_static)
>  		fdb_del_hw_addr(br, f->addr.addr);
>  
> -	if (f->added_by_external_learn)
> -		fdb_del_external_learn(f);
> -
>  	hlist_del_init_rcu(&f->hlist);
>  	fdb_notify(br, f, RTM_DELNEIGH);
>  	call_rcu(&f->rcu, fdb_rcu_free);
> 
Reviewed-by: Ivan Vecera <ivecera@redhat.com>
