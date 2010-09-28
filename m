From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16603] New: send of data > 4 GB fails on 64
 bit systems
Date: Mon, 27 Sep 2010 20:56:24 -0700
Message-ID: <20100927205624.1564649e.akpm@linux-foundation.org>
References: <bug-16603-10286@https.bugzilla.kernel.org/>
	<20100927161540.776f748e.akpm@linux-foundation.org>
	<20100927.202425.71120040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, bono@onlinehome.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52511 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752123Ab0I1Dzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 23:55:52 -0400
In-Reply-To: <20100927.202425.71120040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Sep 2010 20:24:25 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> Ok, I suspect the following is enough to fix this specific bug
> report, TCP sending.
> 
> However, as I stated in my previous reply there are creepy
> crawlies all over the place.
> 
> For example, all of the routines in net/core/iovec.c (memcpy_toiovec,
> memcpy_toiovecend, memcpy_fromiovec, memcpy_fromiovecend,
> csum_partial_copy_fromiovecend) that cast using min_t() are currently
> casting "down" to "unsigned int".
> 
> They should probably case "up" to "size_t".

eep.

A blanket suckyfix might be, at the syscall level:

	if (size > 4g) {
		do_it_in_4g_hunks();
		do_the_last_bit();
	}

unless that would break some networking syscall->framesize guarantees
or something?

And such a "fix" would make it hard to test the real fix!


I'm surprised that this issue hasn't come up before.
