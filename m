From: David Miller <davem@davemloft.net>
Subject: Re: bad unlock balance detected during stress
Date: Wed, 03 Feb 2010 14:49:15 -0800 (PST)
Message-ID: <20100203.144915.65349431.davem@davemloft.net>
References: <EA929A9653AAE14F841771FB1DE5A1365FDD5CAF52@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51735
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754668Ab0BCWtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 17:49:03 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FDD5CAF52@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Wed, 3 Feb 2010 13:05:44 -0700

> I got this panic while running netperf stress test using recent pull from net-next:

Known bug, fixed yesterday by Patrick McHardy:

commit d1c9ae6d1e7b95cedc8e39e8949e795379a0669e
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Feb 2 11:46:50 2010 -0800

    ipv4: ip_fragment: fix unbalanced rcu_read_unlock()
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 9f41bd3..b59430b 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -234,10 +234,9 @@ static void ip_expire(unsigned long arg)
 
 		/* Send an ICMP "Fragment Reassembly Timeout" message. */
 		icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
-	}
-
 out_rcu_unlock:
-	rcu_read_unlock();
+		rcu_read_unlock();
+	}
 out:
 	spin_unlock(&qp->q.lock);
 	ipq_put(qp);
