From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: percpu nh_rth_output cache
Date: Tue, 31 Jul 2012 17:29:56 +0200
Message-ID: <1343748596.21269.315.camel@edumazet-glaptop>
References: <1343748166.21269.304.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45849 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441Ab2GaP37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 11:29:59 -0400
Received: by bkwj10 with SMTP id j10so3349973bkw.19
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2012 08:29:58 -0700 (PDT)
In-Reply-To: <1343748166.21269.304.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-31 at 17:22 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 

> +		p = per_cpu_ptr(nh->nh_pcpu_rth_output,
> +				raw_smp_processor_id());
> +	}

Note : this can use :

	p = __this_cpu_ptr(nh->nh_pcpu_rth_output);

and same thing in __mkroute_output()

prth = __this_cpu_ptr(FIB_RES_NH(*res).nh_pcpu_rth_output);
