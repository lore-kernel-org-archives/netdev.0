From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC PATCH 0/4] Clarify and cleanup some __GFP_NOFAIL usage
Date: Mon,  2 Mar 2015 14:54:39 +0100
Message-ID: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Dave Chinner <david@fromorbit.com>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Mel Gorman <mgorman@suse.de>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	"David S. Miller" <davem@davemloft.net>,
	sparclinux@vger.kernel.org,
	Vipul Pandya <vipul@chelsio.com>,
	netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: <linux-mm@kvack.org>
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hi,
from the last discussion about __GFP_NOFAIL it turned out that the flag
cannot be deprecated as easily as MM people hoped for.
The current flag description leads people to inventing their own loops
around GFP_{KERNEL|NOFS} allocations without any fallback failure
policy. This makes the situation much worse for the MM layer because it
is not aware of the hard no-fail requirements.

First patch in this series tries to rephrase the documentation to be
more clear about our intention. __GFP_NOFAIL is generally discouraged
but users shouldn't lie to the allocator if they really cannot have any
failure strategy.

Second patch removes such an open coded retry loop in the jbd2 code
which was introduced exactly because of the deprecation wording. I am
not sure the patch is still required because Ted has mentioned something
about changing this code. If he was faster then we can simply drop
this one. I was hoping for more such opencoded paths but wasn't very
successful. The next plan is to abuse coccinelle to find such patterns.

The last two patches are attempts to get rid of __GFP_NOFAIL when
it seemed they are not needed because there are error paths handled
properly. I am not familiar with that code so I might be clearly
wrong here and I would appreciate double checking from the respective
maintainer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
