From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ip: initialize hash list
Date: Sat, 20 Jul 2013 10:46:20 -0700
Message-ID: <1374342380.1940.2.camel@joe-AO722>
References: <20130720102657.768a11ea@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54973 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754151Ab3GTRqW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jul 2013 13:46:22 -0400
In-Reply-To: <20130720102657.768a11ea@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-07-20 at 10:26 -0700, Stephen Hemminger wrote:
> Rather than relying on the assumption that zero means empty on
> hash list head, the code should use the initialization macro.
> Same effect, but follows API and avoids future breakage if hlist
> implementation changes.
[]
> --- a/net/ipv4/ip_tunnel.c	2013-07-19 09:12:37.213529343 -0700
[]
> -	itn->tunnels = kzalloc(IP_TNL_HASH_SIZE * sizeof(struct hlist_head), GFP_KERNEL);
> +	itn->tunnels = kmalloc(IP_TNL_HASH_SIZE * sizeof(struct hlist_head),
> +			       GFP_KERNEL);
>  	if (!itn->tunnels)
>  		return -ENOMEM;
> +
> +	for (i = 0; i < IP_TNL_HASH_SIZE; i++)
> +		INIT_HLIST_HEAD(&itn->tunnels[i]);

Hey Stephen.

Are you doing to do just this one or submit a series?

$ git grep "alloc.*sizeof.*hlist_head"
drivers/gpu/drm/i915/i915_gem_execbuffer.c:             eb = kzalloc(count*sizeof(struct hlist_head) +
drivers/md/dm-bufio.c:  c->cache_hash = vmalloc(sizeof(struct hlist_head) << DM_BUFIO_HASH_BITS);
fs/ecryptfs/messaging.c:        ecryptfs_daemon_hash = kmalloc((sizeof(struct hlist_head)
fs/nfsd/nfscache.c:     cache_hash = kcalloc(hashsize, sizeof(struct hlist_head), GFP_KERNEL);
kernel/trace/ftrace.c:  stat->hash = kzalloc(sizeof(struct hlist_head) * size, GFP_KERNEL);
lib/lru_cache.c:        slot = kcalloc(e_count, sizeof(struct hlist_head), GFP_KERNEL);
net/ipv4/ip_tunnel.c:   itn->tunnels = kzalloc(IP_TNL_HASH_SIZE * sizeof(struct hlist_head), GFP_KERNEL);
net/mac80211/mesh_pathtbl.c:    newtbl->hash_buckets = kzalloc(sizeof(struct hlist_head) *
net/mac80211/mesh_pathtbl.c:    tbl_path->known_gates = kzalloc(sizeof(struct hlist_head), GFP_ATOMIC);
net/mac80211/mesh_pathtbl.c:    tbl_mpp->known_gates = kzalloc(sizeof(struct hlist_head), GFP_ATOMIC);
net/openvswitch/datapath.c:     dp->ports = kmalloc(DP_VPORT_HASH_BUCKETS * sizeof(struct hlist_head),
net/openvswitch/flow.c: buckets = flex_array_alloc(sizeof(struct hlist_head *),
net/openvswitch/vport.c:        dev_table = kzalloc(VPORT_HASH_BUCKETS * sizeof(struct hlist_head),
net/tipc/name_table.c:  table.types = kcalloc(TIPC_NAMETBL_SIZE, sizeof(struct hlist_head),
virt/kvm/irqchip.c:     new = kzalloc(sizeof(*new) + (nr_rt_entries * sizeof(struct hlist_head))
