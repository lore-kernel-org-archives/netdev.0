From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 4/8] tipc: mark head of
	reassembly buffer as non-linear
Date: Fri,  9 May 2014 09:13:25 -0400
Message-ID: <1399641209-26112-5-git-send-email-jon.maloy@ericsson.com>
References: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The message reassembly function does not update the 'len' and 'data_len'
fields of the head skbuff correctly when fragments are chained to it.
This may sometimes lead to obsure errors, such as fragment reordering
when we receive fragments which are cloned buffers.

This commit fixes this, by ensuring that the two fields are updated
correctly.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 6cf7938..9272d4c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2341,6 +2341,8 @@ int tipc_link_frag_rcv(struct sk_buff **head, struct sk_buff **tail,
 			(*tail)->next = frag;
 		*tail = frag;
 		(*head)->truesize += frag->truesize;
+		(*head)->data_len += frag->len;
+		(*head)->len += frag->len;
 	}
 	if (fragid == LAST_FRAGMENT) {
 		*fbuf = *head;
-- 
1.7.9.5


------------------------------------------------------------------------------
Is your legacy SCM system holding you back? Join Perforce May 7 to find out:
&#149; 3 signs your SCM is hindering your productivity
&#149; Requirements for releasing software faster
&#149; Expert tips and advice for migrating your SCM now
http://p.sf.net/sfu/perforce
