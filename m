From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] tcp_cubic: better follow cubic curve after
 idle period
Date: Thu, 10 Sep 2015 10:59:06 -0700 (PDT)
Message-ID: <20150910.105906.1350790432465932740.davem@davemloft.net>
References: <1441808667.4619.21.camel@edumazet-glaptop2.roam.corp.google.com>
	<1441860907.4619.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
	jri@google.com, stephen@networkplumber.org, sangtae.ha@gmail.com,
	lawrence@brakmo.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163AbbIJR7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 13:59:07 -0400
In-Reply-To: <1441860907.4619.44.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Sep 2015 21:55:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Jana Iyengar found an interesting issue on CUBIC :
> 
> The epoch is only updated/reset initially and when experiencing losses.
> The delta "t" of now - epoch_start can be arbitrary large after app idle
> as well as the bic_target. Consequentially the slope (inverse of
> ca->cnt) would be really large, and eventually ca->cnt would be
> lower-bounded in the end to 2 to have delayed-ACK slow-start behavior.
> 
> This particularly shows up when slow_start_after_idle is disabled
> as a dangerous cwnd inflation (1.5 x RTT) after few seconds of idle
> time.
> 
> Jana initial fix was to reset epoch_start if app limited,
> but Neal pointed out it would ask the CUBIC algorithm to recalculate the
> curve so that we again start growing steeply upward from where cwnd is
> now (as CUBIC does just after a loss). Ideally we'd want the cwnd growth
> curve to be the same shape, just shifted later in time by the amount of
> the idle period.
> 
> Reported-by: Jana Iyengar <jri@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
