From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netlink: fix typo in initialization
Date: Thu, 08 Oct 2009 00:57:43 -0700 (PDT)
Message-ID: <20091008.005743.231834593.davem@davemloft.net>
References: <20091008072323.GA3255@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34486
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754891AbZJHH5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 03:57:48 -0400
In-Reply-To: <20091008072323.GA3255@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 8 Oct 2009 09:23:23 +0200

> Commit 9ef1d4c7c7aca1cd436612b6ca785b726ffb8ed8 introduced a typo in
> initialization. This patch fixes this.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Doesn't this leak some uninitialized bytes to userspace?

Therefore, this fix probably belongs in net-2.6 and -stable instead
of net-next-2.6, right?

> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index 6a53694..7cf6c0f 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -350,7 +350,7 @@ static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
>  	tcm = NLMSG_DATA(nlh);
>  	tcm->tcm_family = AF_UNSPEC;
>  	tcm->tcm__pad1 = 0;
> -	tcm->tcm__pad1 = 0;
> +	tcm->tcm__pad2 = 0;
>  	tcm->tcm_ifindex = qdisc_dev(tp->q)->ifindex;
>  	tcm->tcm_parent = tp->classid;
>  	tcm->tcm_info = TC_H_MAKE(tp->prio, tp->protocol);
