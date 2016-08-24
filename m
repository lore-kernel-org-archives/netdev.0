From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next] net: minor optimization in
 qdisc_qstats_cpu_drop()
Date: Wed, 24 Aug 2016 11:04:43 -0700
Message-ID: <f4e3fe14-ddbb-5b37-d003-46f28f7d8750@hpe.com>
References: <1472059414.14381.101.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hpe.com ([15.241.32.99]:31146 "EHLO
        g9t1613g.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754707AbcHXSFq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 14:05:46 -0400
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com [15.241.140.73])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g9t1613g.houston.hpe.com (Postfix) with ESMTPS id 287E562639
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 18:05:45 +0000 (UTC)
In-Reply-To: <1472059414.14381.101.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2016 10:23 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> per_cpu_inc() is faster (at least on x86) than per_cpu_ptr(xxx)++;

Is it possible it is non-trivially slower on other architectures?

rick jones

>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/net/sch_generic.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 0d501779cc68f9426e58da6d039dd64adc937c20..52a2015667b49c8315edbb26513a98d4c677fee5 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -592,7 +592,7 @@ static inline void qdisc_qstats_drop(struct Qdisc *sch)
>
>  static inline void qdisc_qstats_cpu_drop(struct Qdisc *sch)
>  {
> -	qstats_drop_inc(this_cpu_ptr(sch->cpu_qstats));
> +	this_cpu_inc(sch->cpu_qstats->drops);
>  }
>
>  static inline void qdisc_qstats_overlimit(struct Qdisc *sch)
>
