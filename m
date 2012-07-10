From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net-next kernel NULL pointer dereference at fib_rules_tclass
Date: Tue, 10 Jul 2012 19:25:01 +0200
Message-ID: <1341941101.3265.5799.camel@edumazet-glaptop>
References: <alpine.LRH.2.00.1207101008270.9760@ogerlitz.voltaire.com>
	 <20120710.094428.1167234955738653678.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org,
	shlomop@mellanox.com, amirv@mellanox.com, erezsh@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:59967 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281Ab2GJRZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 13:25:07 -0400
Received: by eeit10 with SMTP id t10so99972eei.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 10:25:05 -0700 (PDT)
In-Reply-To: <20120710.094428.1167234955738653678.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 09:44 -0700, David Miller wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Tue, 10 Jul 2012 10:16:55 +0300
> 
> > Starting system logger: BUG: unable to handle kernel NULL pointer dereference at 00000000000000ac
> > IP: [<ffffffff81320393>] fib_rules_tclass+0xf/0x17
> 
> Ok, fib_rules_tclass() checks for res->r being NULL and only
> dereferences it if it is not.
> 
> fib4_rule->tclassid has offset ~0x8c on x86-64, and this fault
> address is 0x10 bytes off.
> 
> Does this patch fix the problem?
> 
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 539c672..000c467 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -230,6 +230,7 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
>  			     struct fib_result *res)
>  {
>  	if (!net->ipv4.fib_has_custom_rules) {
> +		res->r = NULL;
>  		if (net->ipv4.fib_local &&
>  		    !fib_table_lookup(net->ipv4.fib_local, flp, res,
>  				      FIB_LOOKUP_NOREF))

It does here, thanks
