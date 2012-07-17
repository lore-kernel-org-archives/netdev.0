From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 0/5] Long term PMTU/redirect storage in ipv4.
Date: Wed, 18 Jul 2012 01:14:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207180052420.2128@ja.ssi.bg>
References: <20120717.061418.1893307699868826531.davem@davemloft.net> <alpine.LFD.2.00.1207172249270.1831@ja.ssi.bg> <20120717.134651.562831385960975623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54936 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757261Ab2GQWG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 18:06:59 -0400
In-Reply-To: <20120717.134651.562831385960975623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 17 Jul 2012, David Miller wrote:

> > 	IIRC, struct fib_info was shared by different
> > prefixes. It saves a lot of memory when thousands of
> > routes are created to same GW. Now if we end up with 1 or
> > 2 fib_info structures for default routes, the nh_exceptions list
> > can become very long. May be fib_info is not a good place
> > to hide such data.
> 
> Your analysis of what fib_info is and how it's intended to
> work is accurate.
> 
> But we don't use a linked list for the exceptions in the final
> version, we use a reclaiming RCU'd hash table like we use for TCP
> metrics.
> 
> See the updated version of patch #5 and what I actually committed to
> net-next.

	Aha, I see. Something around fnhe_oldest() and its
daddr arg does not look good. If the goal is to hijack
some entry, probably for another daddr and comparing it with
tcpm_new(), may be we should remove this daddr arg and fully
reset all parameters such as fnhe_pmtu, fnhe_gw, fnhe_expires
because the find_or_create_fnhe() callers modify only specific
fields, we should not end up with wrong gateway inherited from
another daddr, for example.

Regards

--
Julian Anastasov <ja@ssi.bg>
