From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 net-next 0/6] allow eBPF programs to be attached to
 sockets
Date: Fri, 05 Dec 2014 21:48:18 -0800 (PST)
Message-ID: <20141205.214818.1275634074992727284.davem@davemloft.net>
References: <1417475199-15950-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417475199-15950-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Mon,  1 Dec 2014 15:06:33 -0800

> V1->V2:
> 
> fixed comments in sample code to state clearly that packet data is accessed
> with LD_ABS instructions and not internal skb fields.
> Also replaced constants in:
> BPF_LD_ABS(BPF_B, 14 + 9 /* R0 = ip->proto */),
> with:
> BPF_LD_ABS(BPF_B, ETH_HLEN + offsetof(struct iphdr, protocol) /* R0 = ip->proto */),
> 
> V1 cover:
> 
> Introduce BPF_PROG_TYPE_SOCKET_FILTER type of eBPF programs that can be
> attached to sockets with setsockopt().
> Allow such programs to access maps via lookup/update/delete helpers.
> 
> This feature was previewed by bpf manpage in commit b4fc1a460f30("Merge branch 'bpf-next'")
> Now it can actually run.
> 
> 1st patch adds LD_ABS/LD_IND instruction verification and
> 2nd patch adds new setsockopt() flag.
> Patches 3-6 are examples in assembler and in C.
> 
> Though native eBPF programs are way more powerful than classic filters
> (attachable through similar setsockopt() call), they don't have skb field
> accessors yet. Like skb->pkt_type, skb->dev->ifindex are not accessible.
> There are sevaral ways to achieve that. That will be in the next set of patches.
> So in this set native eBPF programs can only read data from packet and
> access maps.
> 
> The most powerful example is sockex2_kern.c from patch 6 where ~200 lines of C
> are compiled into ~300 of eBPF instructions.
> It shows how quite complex packet parsing can be done.
> 
> LLVM used to build examples is at https://github.com/iovisor/llvm
> which is fork of llvm trunk that I'm cleaning up for upstreaming.

Series applied, thanks.
