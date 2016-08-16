From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] net: sched: fix handling of singleton qdiscs with
 qdisc_hash
Date: Tue, 16 Aug 2016 16:34:14 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608161631110.22028@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1608161238590.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1608161238590.22028@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Aug 2016, Jiri Kosina wrote:

> From: Jiri Kosina <jkosina@suse.cz>
> 
> qdisc_match_from_root() is now iterating over per-netdevice qdisc 
> hashtable instead of going through a linked-list of qdiscs (independently 
> on the actual underlying netdev), which used to be the case before the 
> switch to hashtable for qdiscs.
> 
> For singleton qdiscs, there is no underlying netdev associated though, and 
> therefore dumping a singleton qdisc will panic, as qdisc_dev(root) will 
> always be NULL.
[ ... snip ... ]
> @@ -1456,6 +1459,10 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
>  			goto done;
>  		q_idx++;
>  	}
> +
> +	if (!qdisc_dev(root))
> +		goto done;
> +

Ok, this will cause default singleton-only devices being missed in the 
dump.

I am now working on creating a automation that'd test as many use cases as 
possible; will send up a new patch once I have all the known corner cases 
covered (including the ingress / clsact dump duplication).

Please drop this one for now, I'll send up an accumulated followup fixes 
asap.

Thanks,

-- 
Jiri Kosina
SUSE Labs
