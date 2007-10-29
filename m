From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH] nf_nat_h323.c unneeded rcu_dereference() calls
Date: Mon, 29 Oct 2007 14:06:18 -0700
Message-ID: <20071029210618.GA4200@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@au1.ibm.com, zhaojingmin@users.sourceforge.net,
	davem@davemloft.net
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:48483 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbXJ2VGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 17:06:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

While reviewing rcu_dereference() uses, I came across a number of cases
where I couldn't see how the rcu_dereference() helped.  One class of
cases is where the variable is never subsequently dereferenced, so that
patches like the following one would be appropriate.

So, what am I missing here?

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 nf_nat_h323.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff -urpNa -X dontdiff linux-2.6.23/net/ipv4/netfilter/nf_nat_h323.c linux-2.6.23-rcufix/net/ipv4/netfilter/nf_nat_h323.c
--- linux-2.6.23/net/ipv4/netfilter/nf_nat_h323.c	2007-10-09 13:31:38.000000000 -0700
+++ linux-2.6.23-rcufix/net/ipv4/netfilter/nf_nat_h323.c	2007-10-29 14:00:13.000000000 -0700
@@ -546,15 +546,15 @@ static int nat_callforwarding(struct sk_
 /****************************************************************************/
 static int __init init(void)
 {
-	BUG_ON(rcu_dereference(set_h245_addr_hook) != NULL);
-	BUG_ON(rcu_dereference(set_h225_addr_hook) != NULL);
-	BUG_ON(rcu_dereference(set_sig_addr_hook) != NULL);
-	BUG_ON(rcu_dereference(set_ras_addr_hook) != NULL);
-	BUG_ON(rcu_dereference(nat_rtp_rtcp_hook) != NULL);
-	BUG_ON(rcu_dereference(nat_t120_hook) != NULL);
-	BUG_ON(rcu_dereference(nat_h245_hook) != NULL);
-	BUG_ON(rcu_dereference(nat_callforwarding_hook) != NULL);
-	BUG_ON(rcu_dereference(nat_q931_hook) != NULL);
+	BUG_ON(set_h245_addr_hook != NULL);
+	BUG_ON(set_h225_addr_hook != NULL);
+	BUG_ON(set_sig_addr_hook != NULL);
+	BUG_ON(set_ras_addr_hook != NULL);
+	BUG_ON(nat_rtp_rtcp_hook != NULL);
+	BUG_ON(nat_t120_hook != NULL);
+	BUG_ON(nat_h245_hook != NULL);
+	BUG_ON(nat_callforwarding_hook != NULL);
+	BUG_ON(nat_q931_hook != NULL);
 
 	rcu_assign_pointer(set_h245_addr_hook, set_h245_addr);
 	rcu_assign_pointer(set_h225_addr_hook, set_h225_addr);
