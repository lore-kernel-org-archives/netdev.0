From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v5] bridge: multicast to unicast
Date: Tue, 24 Jan 2017 10:10:41 -0800
Message-ID: <20170124101041.55c2ab39@xeon-e3>
References: <20170121200133.1864-1-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Felix Fietkau <nbd@nbd.name>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: Linus =?UTF-8?B?TMO8c3Npbmc=?= <linus.luessing@c0d3.blue>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170121200133.1864-1-linus.luessing@c0d3.blue>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 21 Jan 2017 21:01:32 +0100
Linus L=C3=BCssing <linus.luessing@c0d3.blue> wrote:

> @@ -726,12 +729,32 @@ struct net_bridge_port_group *br_multicast_new_port=
_group(
>  	hlist_add_head(&p->mglist, &port->mglist);
>  	setup_timer(&p->timer, br_multicast_port_group_expired,
>  		    (unsigned long)p);
> +
> +	if (src)
> +		memcpy(p->eth_addr, src, ETH_ALEN);
> +	else
> +		memset(p->eth_addr, 0xff, ETH_ALEN);
> +
>  	return p;
>  }

Maybe use ether_addr_copy here, but is not performance critical
