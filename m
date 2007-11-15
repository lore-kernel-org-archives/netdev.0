From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] NET : rt_check_expire() can take a long time, add a cond_resched()
Date: Thu, 15 Nov 2007 08:30:16 +0100
Message-ID: <p73r6isc6ev.fsf@bingen.suse.de>
References: <473B69D5.2050805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45544 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756887AbXKOHaS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 02:30:18 -0500
In-Reply-To: <473B69D5.2050805@cosmosbay.com> (Eric Dumazet's message of "Wed\, 14 Nov 2007 22\:34\:13 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> writes:
>
> Using a "if (need_resched())" test before calling "cond_resched();" is
> necessary to avoid spending too much time doing the resched check.

The only difference between cond_resched() and if (need_resched())
cond_resched() is one function call less and one might_sleep less. If
the might_sleep or the function call are really problems (did you
measure it? -- i doubt it somewhat) then it would be better to fix the
generic code to either inline that or supply a __cond_resched()
without might_sleep.

A cheaper change might have been to just limit the number of buckets
scanned.

-Andi
