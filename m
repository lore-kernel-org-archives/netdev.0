From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH] net: convert to rcu_dereference_index_check()
Date: Fri, 6 Aug 2010 14:26:07 -0700
Message-ID: <20100806212607.GA9410@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, arnd@arndb.de
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Herbert!

At long last, the following is the final patch blocking acceptance
of Arnd's sparse annotations for RCU.  It was itself blocked behind
the definition of rcu_dereference_index_check(), which made it to
mainline only just today.

Would you be willing to ack this patch so that I can push it to -tip,
along with Arnd's work and a bunch of other stuff?

							Thanx, Paul

------------------------------------------------------------------------

commit 34ea15566530f8e4d0c1571cc8c3554fd91d5809
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Mon Jun 14 17:06:21 2010 -0700

    net: convert to rcu_dereference_index_check()
    
    The task_cls_classid() function applies rcu_dereference() to integers,
    which does not work with the shiny new sparse-based checking in
    rcu_dereference().  This commit therefore moves to the new RCU API
    rcu_dereference_index_check().
    
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
    Reviewed-by: Josh Triplett <josh@joshtriplett.org>

 cls_cgroup.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 726cc35..dd1fdb8 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -45,7 +45,8 @@ static inline u32 task_cls_classid(struct task_struct *p)
 		return 0;
 
 	rcu_read_lock();
-	id = rcu_dereference(net_cls_subsys_id);
+	id = rcu_dereference_index_check(net_cls_subsys_id,
+					 rcu_read_lock_held());
 	if (id >= 0)
 		classid = container_of(task_subsys_state(p, id),
 				       struct cgroup_cls_state, css)->classid;
