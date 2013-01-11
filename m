From: Eric Wong <normalperson@yhbt.net>
Subject: Re: 3.8-rc2/rc3 write() blocked on CLOSE_WAIT TCP socket
Date: Fri, 11 Jan 2013 02:50:39 +0000
Message-ID: <20130111025039.GA4723@dcvr.yhbt.net>
References: <20130111004915.GA15415@dcvr.yhbt.net>
 <1357869675.27446.2962.camel@edumazet-glaptop>
 <1357870727.27446.2988.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>,
	Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1357870727.27446.2988.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
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

All good here, thanks for the quick turnaround!

Tested-by: Eric Wong <normalperson@yhbt.net>

(I originally thought the FIFOs were part of the problem, so I left
 that in my test case)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
