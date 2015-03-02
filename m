From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 3/4] sparc: remove __GFP_NOFAIL reuquirement
Date: Mon, 02 Mar 2015 15:04:05 -0500 (EST)
Message-ID: <20150302.150405.2072800922470200977.davem@davemloft.net>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
	<1425304483-7987-4-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org,
 rientjes@google.com, david@fromorbit.com, tytso@mit.edu, mgorman@suse.de,
 penguin-kernel@I-love.SAKURA.ne.jp, sparclinux@vger.kernel.org,
 vipul@chelsio.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mhocko@suse.cz
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1425304483-7987-4-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Michal Hocko <mhocko@suse.cz>
Date: Mon,  2 Mar 2015 14:54:42 +0100

> mdesc_kmalloc is currently requiring __GFP_NOFAIL allocation although it
> seems that the allocation failure is handled by all callers (via
> mdesc_alloc). __GFP_NOFAIL is a strong liability for the memory
> allocator and so the users are discouraged to use the flag unless the
> allocation failure is really a nogo. Drop the flag here as this doesn't
> seem to be the case.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

It is a serious failure.

If we miss an MDESC update due to this allocation failure, the update
is not an event which gets retransmitted so we will lose the updated
machine description forever.

We really need this allocation to succeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
