From: David Miller <davem@davemloft.net>
Subject: Re: net-next kernel NULL pointer dereference at fib_rules_tclass
Date: Tue, 10 Jul 2012 18:05:43 -0700 (PDT)
Message-ID: <20120710.180543.1460678493453873565.davem@davemloft.net>
References: <20120710.094428.1167234955738653678.davem@davemloft.net>
	<1341941101.3265.5799.camel@edumazet-glaptop>
	<20120710111434.00003ba8@unknown>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ogerlitz@mellanox.com,
	netdev@vger.kernel.org, shlomop@mellanox.com, amirv@mellanox.com,
	erezsh@mellanox.com
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681Ab2GKBFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 21:05:44 -0400
In-Reply-To: <20120710111434.00003ba8@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>
Date: Tue, 10 Jul 2012 11:14:34 -0700

> On Tue, 10 Jul 2012 19:25:01 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> On Tue, 2012-07-10 at 09:44 -0700, David Miller wrote:
>> > From: Or Gerlitz <ogerlitz@mellanox.com>
>> > Date: Tue, 10 Jul 2012 10:16:55 +0300
>> > 
>> > > Starting system logger: BUG: unable to handle kernel NULL pointer
>> > > dereference at 00000000000000ac IP: [<ffffffff81320393>]
>> > > fib_rules_tclass+0xf/0x17
>> > 
>> > Ok, fib_rules_tclass() checks for res->r being NULL and only
>> > dereferences it if it is not.
>> > 
>> > fib4_rule->tclassid has offset ~0x8c on x86-64, and this fault
>> > address is 0x10 bytes off.
>> > 
>> > Does this patch fix the problem?
>> > 
>> > diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
>> > index 539c672..000c467 100644
>> > --- a/include/net/ip_fib.h
>> > +++ b/include/net/ip_fib.h
>> > @@ -230,6 +230,7 @@ static inline int fib_lookup(struct net *net,
>> > struct flowi4 *flp, struct fib_result *res)
>> >  {
>> >  	if (!net->ipv4.fib_has_custom_rules) {
>> > +		res->r = NULL;
>> >  		if (net->ipv4.fib_local &&
>> >  		    !fib_table_lookup(net->ipv4.fib_local, flp,
>> > res, FIB_LOOKUP_NOREF))
>> 
>> It does here, thanks
> 
> Works for me too.

Great, pushed out to net-next, thanks everyone.
