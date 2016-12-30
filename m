From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: make tcp_notsent_lowat sysctl knob behave as
 true unsigned int
Date: Fri, 30 Dec 2016 15:23:25 -0500 (EST)
Message-ID: <20161230.152325.1460360247883491150.davem@davemloft.net>
References: <20161229143507.4934-1-ptikhomirov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, khorenko@virtuozzo.com
To: ptikhomirov@virtuozzo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45982 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752859AbcL3UX2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 15:23:28 -0500
In-Reply-To: <20161229143507.4934-1-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Date: Thu, 29 Dec 2016 17:35:07 +0300

> @@ -958,7 +959,9 @@ static struct ctl_table ipv4_net_table[] = {
>  		.data		= &init_net.ipv4.sysctl_tcp_notsent_lowat,
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
> -		.proc_handler	= proc_dointvec,
> +		.proc_handler	= proc_doulongvec_minmax,
> +		.extra1		= &zero,
> +		.extra2		= &uint_max,

It seems much simpler to use "proc_douintvec()" to fix this bug.

Doesn't it?
