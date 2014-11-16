From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 net-next 6/7] bpf: allow eBPF programs to use maps
Date: Sun, 16 Nov 2014 14:04:22 -0500 (EST)
Message-ID: <20141116.140422.570375628237589645.davem@davemloft.net>
References: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
	<1415929010-9361-7-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415929010-9361-7-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Thu, 13 Nov 2014 17:36:49 -0800

> +static u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +	/* verifier checked that R1 contains a valid pointer to bpf_map
> +	 * and R2 points to a program stack and map->key_size bytes were
> +	 * initialized
> +	 */
> +	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
> +	void *key = (void *) (unsigned long) r2;
> +	void *value;
> +
> +	WARN_ON_ONCE(!rcu_read_lock_held());
> +
> +	value = map->ops->map_lookup_elem(map, key);
> +
> +	/* lookup() returns either pointer to element value or NULL
> +	 * which is the meaning of PTR_TO_MAP_VALUE_OR_NULL type
> +	 */
> +	return (unsigned long) value;
> +}

You should translate this into a true boolean '1' or '0' value so that
kernel pointers don't propagate to the user or his eBPF programs.
