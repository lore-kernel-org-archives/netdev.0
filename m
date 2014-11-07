From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 06/10] bridge: introduce fdb offloading via
 switchdev
Date: Fri, 07 Nov 2014 15:12:44 -0500 (EST)
Message-ID: <20141107.151244.1667277873637218117.davem@davemloft.net>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
	<1415265610-9338-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbaKGUMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 15:12:52 -0500
In-Reply-To: <1415265610-9338-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  6 Nov 2014 10:20:06 +0100

> @@ -132,8 +133,12 @@ static void fdb_del_hw(struct net_bridge *br, const unsigned char *addr)
>  
>  static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
>  {
> -	if (f->is_static)
> +	if (f->is_static) {
>  		fdb_del_hw(br, f->addr.addr);
> +		if (f->dst)
> +			netdev_sw_port_fdb_del(f->dst->dev,
> +					       f->addr.addr, f->vlan_id);
> +	}
>  
>  	hlist_del_rcu(&f->hlist);
>  	fdb_notify(br, f, RTM_DELNEIGH);

I think we should now adjust the name of fdb_*_hw() because
fdb_del_hw() sounds like a function that would do what
netdev_sw_port_fdb_del() actually does, remove the fdb entry from the
hardware.  But it just removes an address from the device's unicast
filter.

Rename them to something like fdb_*_hw_address() of fdb_*_hw_addr().

Thanks.
