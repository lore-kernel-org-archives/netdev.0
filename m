From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] net: minor optimization in
 qdisc_qstats_cpu_drop()
Date: Wed, 24 Aug 2016 11:00:28 -0700
Message-ID: <57BDE0BC.9040607@gmail.com>
References: <1472059414.14381.101.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33845 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753374AbcHXSAn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 14:00:43 -0400
Received: by mail-pf0-f195.google.com with SMTP id g202so1622852pfb.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 11:00:39 -0700 (PDT)
In-Reply-To: <1472059414.14381.101.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-24 10:23 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> per_cpu_inc() is faster (at least on x86) than per_cpu_ptr(xxx)++;
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
> 

Looks good to me. I guess we can also do the same for overlimit qstats.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
