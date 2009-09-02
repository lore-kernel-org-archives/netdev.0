From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] tc: Fix unitialized kernel memory leak
Date: Wed, 2 Sep 2009 20:09:36 +0200
Message-ID: <20090902180935.GA2849@psychotron.redhat.com>
References: <4A9E67A9.7090205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65017 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102AbZIBSJm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 14:09:42 -0400
Content-Disposition: inline
In-Reply-To: <4A9E67A9.7090205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 02, 2009 at 02:40:09PM CEST, eric.dumazet@gmail.com wrote:
>Three bytes of uninitialized kernel memory are currently leaked to user
>
>Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Reviewed-by: Jiri Pirko <jpirko@redhat.com>

>---
>diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
>index 24d17ce..fdb694e 100644
>--- a/net/sched/sch_api.c
>+++ b/net/sched/sch_api.c
>@@ -1456,6 +1456,8 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
> 	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
> 	tcm = NLMSG_DATA(nlh);
> 	tcm->tcm_family = AF_UNSPEC;
>+	tcm->tcm__pad1 = 0;
>+	tcm->tcm__pad2 = 0;
> 	tcm->tcm_ifindex = qdisc_dev(q)->ifindex;
> 	tcm->tcm_parent = q->handle;
> 	tcm->tcm_handle = q->handle;
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
