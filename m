From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] include/net/genetlink.h: Allow genlmsg_cancel to
 accept a NULL argument
Date: Thu, 03 Feb 2011 20:43:41 -0800 (PST)
Message-ID: <20110203.204341.193732974.davem@davemloft.net>
References: <Pine.LNX.4.64.1101281642080.8546@pc-004.diku.dk>
	<20110201.145410.115936566.davem@davemloft.net>
	<Pine.LNX.4.64.1102020659520.9302@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paul.moore@hp.com, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1102020659520.9302@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Wed, 2 Feb 2011 07:17:29 +0100 (CET)

> This pattern occurred in eg:
> 
> net/netlabel/netlabel_unlabeled.c
> 
> in the function netlbl_unlabel_staticlist_gen and in other netlabel code, 
> as well as in net/wireless/nl80211.c, but with the function nl80211hdr_put 
> instead of genlmsg_put.  I submitted patches for all of these cases, so 
> that is perhaps why you don't see them.  But someone suggested to change 
> genlmsg_cancel as well, to be as permissive as nlmsg_cancel.
> 
> For nlmsg_cancel, there are two occurrences in 
> net/netfilter/nf_conntrack_netlink.c where nlmsg_cancel is reachable with 
> the second argument NULL.
> 
> For nlmsg_cancel the ability to accept NULL as a second argument comes 
> from the fact that it only calls nlmsg_trim, which does nothing if NULL is 
> the second argument.  nlmsg_trim is also called by nla_nest_cancel.  There 
> are many calls to nla_nest_cancel with NULL as the second argument in the 
> directory net/sched, for example in the function gred_dump in 
> net/sched/sch_gred.c.  net/sched also contains a call to nlmsg_trim with 
> NULL as the second argument, in the function flow_dump, in 
> net/sched/cls_flow.c.
> 
> The whole thing seems somewhat sloppy.  I'm sure that all of the 
> above-cited occurrences could be rewritten as outlined above to skip over 
> the cancel/trim function.

Thanks for the analysis Julia.

I think the only safe thing to do in net-2.6 and -stable is to add
the NULL check to genlmsg_cancel() as your patch did.

I we later want to move things such that, consistently, we never
call *nlmsg_cancel() with a NULL second arg, that's fine.

I'll apply your genlmsg_cancel() patch, thanks Julia.
