From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 3/6] samples: bpf: example of stateful socket
 filtering
Date: Sat, 29 Nov 2014 21:01:58 -0800 (PST)
Message-ID: <20141129.210158.2021042941461629799.davem@davemloft.net>
References: <1417066951-1999-1-git-send-email-ast@plumgrid.com>
	<1417066951-1999-4-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417066951-1999-4-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Wed, 26 Nov 2014 21:42:28 -0800

> this socket filter example does:
> - creates arraymap in kernel with key 4 bytes and value 8 bytes
> 
> - loads eBPF program:
>   r0 = skb[14 + 9]; // load one byte of ip->proto
 ...
> +		BPF_LD_ABS(BPF_B, 14 + 9 /* R0 = ip->proto */),

I do not want anything having to do with fixed offsets from
the skb.

Nothing should know where things are in the SKB structure,
especially user facing things.

That's why we have explicit BPF operations for fetching
specific SKB members, so that the layout is completely
transparent to the entity generating BPF programs.

Besides retaining the flexibility of changing the SKB
layout arbitrarily without breaking bpf programs, there
are also security considerations from allowing bpf
programs to load arbitrary offsets.

Sorry, I do not like this patch series at all.
