From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] pktgen - define and use pktgen_dbg,err,warn,info
Date: Tue, 31 Jul 2007 16:48:06 -0700
Message-ID: <1185925686.14777.22.camel@localhost>
References: <1184796853.5863.40.camel@localhost>
	 <20070718.154950.91758269.davem@davemloft.net>
	 <1184800861.5863.54.camel@localhost>
	 <20070730.160540.48528135.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4882 "EHLO Perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754086AbXGaXsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 19:48:21 -0400
In-Reply-To: <20070730.160540.48528135.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-07-30 at 16:05 -0700, David Miller wrote:
> I still don't know about this patch.  Instead of the simple
> transformation:
> 
> -	printk(foo);
> +	printk(KERN_INFO foo);
> 
> we get this new macro, and the lines changes to use that macro.

Actually, I agree.

Many local macros could be eliminated that define
printk(<level> prefix)

I'd like to see macros added to kernel.h for:

	pr_err
	pr_notice
	pr_warn
	pr_alert
	pr_crit
	pr_emerge

and convert tree-wide all the single-line

	printk(KERN_<level> [prefix] fmt "\n", args...)

calls to the equivalent pr_<level> calls.

That would leave the multi-line printk(<level>...) calls
to be sorted out so these messages might no longer be
interleaved by multiple cpus/threads.

