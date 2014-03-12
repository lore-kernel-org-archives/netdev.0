From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Avoid unnecessary temporary addresses being
 generated
Date: Wed, 12 Mar 2014 16:48:14 -0400 (EDT)
Message-ID: <20140312.164814.33998602249906578.davem@davemloft.net>
References: <5320BB4C.9060400@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: heiner.kallweit@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbaCLUsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 16:48:15 -0400
In-Reply-To: <5320BB4C.9060400@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiner Kallweit <heiner.kallweit@web.de>
Date: Wed, 12 Mar 2014 20:53:48 +0100

> @@ -1103,8 +1103,11 @@ retry:
>  	 * Lifetime is greater than REGEN_ADVANCE time units.  In particular,
>  	 * an implementation must not create a temporary address with a zero
>  	 * Preferred Lifetime.
> +	 * Use age calculation as in addrconf_verify to avoid unnecessary
> +	 * temporary addresses being generated.
>  	 */
> -	if (tmp_prefered_lft <= regen_advance) {
> +	age = (now - ifp->tstamp + ADDRCONF_TIMER_FUZZ_MINUS) / HZ;
> +	if (tmp_prefered_lft <= regen_advance + age) {

I think you must use tmp_tstamp here, we snapshot all of the values
above into local variables while holding the lock so that we calculate
a consistent set of values and tests.
