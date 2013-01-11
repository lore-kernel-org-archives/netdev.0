From: Neal Cardwell <ncardwell@google.com>
Subject: Re: 3.8-rc2/rc3 write() blocked on CLOSE_WAIT TCP socket
Date: Thu, 10 Jan 2013 21:40:01 -0500
Message-ID: <CADVnQy==hkO5jFH9ah3U-1Joy2D-wkRq80n0dHf6HxfRLS9Hjg@mail.gmail.com>
References: <20130111004915.GA15415@dcvr.yhbt.net>
	<1357869675.27446.2962.camel@edumazet-glaptop>
	<1357870727.27446.2988.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Wong <normalperson@yhbt.net>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Mel Gorman <mgorman@suse.de>,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
	Rik van Riel <riel@redhat.com>,
	Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:51898 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071Ab3AKCkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 21:40:04 -0500
Received: by mail-ee0-f54.google.com with SMTP id c13so633521eek.13
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 18:40:02 -0800 (PST)
In-Reply-To: <1357870727.27446.2988.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2013 at 9:18 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> On Thu, 2013-01-10 at 18:01 -0800, Eric Dumazet wrote:
>
>> Hmm, it might be commit c3ae62af8e755ea68380fb5ce682e60079a4c388
>> tcp: should drop incoming frames without ACK flag set
>>
>> It seems RST should be allowed to not have ACK set.
>>
>> I'll send a fix, thanks !
>
> Yes, thats definitely the problem, sorry for that.
>
>
> [PATCH] tcp: accept RST without ACK flag
>
> commit c3ae62af8e755 (tcp: should drop incoming frames without ACK flag
> set) added a regression on the handling of RST messages.
>
> RST should be allowed to come even without ACK bit set. We validate
> the RST by checking the exact sequence, as requested by RFC 793 and
> 5961 3.2, in tcp_validate_incoming()
>
> Reported-by: Eric Wong <normalperson@yhbt.net>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
