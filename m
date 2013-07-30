From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH v2 2/2] fib_rules: add .suppress operation
Date: Tue, 30 Jul 2013 09:23:05 +0200
Message-ID: <20130730072305.GB10550@zirkel.wertarbyte.de>
References: <20130727070758.GA23904@order.stressinduktion.org>
 <20130730065317.GH13357@zirkel.wertarbyte.de>
 <20130730.000306.1057653828787681847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	bsderandrew@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:47888 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab3G3HXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 03:23:08 -0400
Content-Disposition: inline
In-Reply-To: <20130730.000306.1057653828787681847.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb David Miller (davem@davemloft.net):

> > +static bool fib4_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg) {
>  ...
> > @@ -119,6 +119,18 @@ out:
> >  	return err;
> >  }
> >  
> > +static bool fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg) {
> > +	struct rt6_info *rt = (struct rt6_info *) arg->result;
> > +	/*
> > +	 * do not accept result if the route does
> > +	 * not meet the required prefix length
> > +	 */
> 
> Please format this stuff correctly.
> 
> Functions are declared like this:
> 
> static type NAME(TYPE ARG1, TYPE ARG2)
> {
> }

Noted and fixed.

> You don't put the openning curly brace at the end of the line with the
> closing parenthesis of the argument list.
> 
> Next, comments are to be formatted:
> 
> 	/* Like
> 	 * this.
> 	 */

Well, to be fair, most comments in the existing code base actually use the style
I employed (in fact, I was copying it), so it seems like a blurry line at least.

                /*
                 * If we need to find a source address for this traffic,
                 * we check the result if it meets requirement of the rule.
                 */
-----8<----
        /*
         * If FIB_RULE_FIND_SADDR is set and we do not have a
         * source address for the traffic, we defer check for
         * source address.
         */
-----8<----
        /* The lock is not required here, the list in unreacheable
         * at the moment this function is called */
-----8<----
                        /* compatibility: if the mark value is non-zero all bits
                         * are compared unless a mask is explicitly specified.
                         */
-----8<----
                /*
                 * There are unresolved goto rules in the list, check if
                 * any of them are pointing to this new rule.
                 */
-----8<----
                /*
                 * Check if this rule is a target to any of them. If so,
                 * disable them. As this operation is eventually very
                 * expensive, it is only performed if goto rules have
                 * actually been added.
                 */
-----8<----
