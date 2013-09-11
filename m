From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: sched: Make netns available for ematch
 extensions
Date: Wed, 11 Sep 2013 07:31:55 -0700
Message-ID: <1378909915.21474.2.camel@edumazet-glaptop>
References: <1378905614-29691-1-git-send-email-kadlec@blackhole.kfki.hu>
	 <1378905614-29691-2-git-send-email-kadlec@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"V. Lavrov" <lve@guap.ru>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:40486 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453Ab3IKOb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 10:31:57 -0400
Received: by mail-pa0-f44.google.com with SMTP id fz6so9350678pac.17
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 07:31:57 -0700 (PDT)
In-Reply-To: <1378905614-29691-2-git-send-email-kadlec@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-11 at 15:20 +0200, Jozsef Kadlecsik wrote:
> Ematch API (change, destroy) doesn't pass netns data to ematch extensions.
> This prevents adding netns support to ipset, which is an ematch too.
> 
> The patch adds the required pointer to "struct tcf_proto", thus
> making it available for every ematch.
> 
> Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> ---
>  include/net/sch_generic.h |    1 +
>  net/sched/cls_api.c       |    1 +
>  2 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index f4eb365..38e5e4b 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -225,6 +225,7 @@ struct tcf_proto {
>  	struct Qdisc		*q;
>  	void			*data;
>  	const struct tcf_proto_ops	*ops;
> +	struct net		*net;
>  };
>  

Note that qdisc_dev(tp->q) should give you the pointer to device

Then ->nd_net gives you the struct net pointer.

On management path, this should be enough ;)
