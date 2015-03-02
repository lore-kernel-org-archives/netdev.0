From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 1/4] mm: Clarify __GFP_NOFAIL deprecation status
Date: Mon,  2 Mar 2015 14:54:40 +0100
Message-ID: <1425304483-7987-2-git-send-email-mhocko@suse.cz>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
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
In-Reply-To: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

__GFP_NOFAIL is documented as a deprecated flag since 478352e789f5 (mm:
add comment about deprecation of __GFP_NOFAIL). This has discouraged
people from using it but in some cases an opencoded endless loop around
allocator has been used instead. So the allocator is not aware of the
de facto __GFP_NOFAIL allocation because this information was not
communicated properly.

Let's make clear that if the allocation context really cannot effort
failure because there is no good failure policy then using __GFP_NOFAIL
is preferable to opencoding the loop outside of the allocator.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/gfp.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 51bd1e72a917..0cf9c2772988 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -57,8 +57,10 @@ struct vm_area_struct;
  * _might_ fail.  This depends upon the particular VM implementation.
  *
  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
- * cannot handle allocation failures.  This modifier is deprecated and no new
- * users should be added.
+ * cannot handle allocation failures. New users should be evaluated carefuly
+ * (and the flag should be used only when there is no reasonable failure policy)
+ * but it is definitely preferable to use the flag rather than opencode endless
+ * loop around allocator.
  *
  * __GFP_NORETRY: The VM implementation must not retry indefinitely.
  *
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
