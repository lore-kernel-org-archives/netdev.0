From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Wed, 16 Jun 2010 16:02:49 -0700
Message-ID: <20100616230249.GJ2457@linux.vnet.ibm.com>
References: <1276657139.19249.50.camel@edumazet-laptop>
 <1276657400.19249.53.camel@edumazet-laptop>
 <20100616033336.GA17440@gondor.apana.org.au>
 <20100615.214702.57478137.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	shemminger@vyatta.com, mst@redhat.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, mpm@selenic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:32852 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755092Ab0FPXCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jun 2010 19:02:51 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5GMm2N9017197
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 18:48:02 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5GN2oIM1605690
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 19:02:50 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5GN2nkw024176
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 19:02:50 -0400
Content-Disposition: inline
In-Reply-To: <20100615.214702.57478137.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 09:47:02PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 16 Jun 2010 13:33:36 +1000
> 
> > On Wed, Jun 16, 2010 at 05:03:20AM +0200, Eric Dumazet wrote:
> >>
> >> I wonder how these patches were tested, Herbert ?
> > 
> > You know, not everyone enables RCU debugging...
> 
> Even though I'm as guilty as you, I have to agree with Eric that
> especially us core folks should be running with the various lock
> debugging options on all the time.
> 
> Maybe someone should add the RCU debugging config option to
> Documentation/SubmitChecklist :-)

How about the following added to Documentation/RCU/checklist.txt?

The first is in mainline, the second partly there, and the third
is still languishing in my tree.  I did manage to remove a dependency
on other maintainers, so things will hopefully move a bit faster.

							Thanx, Paul

diff --git a/Documentation/RCU/checklist.txt b/Documentation/RCU/checklist.txt
index 790d1a8..c7c6788 100644
--- a/Documentation/RCU/checklist.txt
+++ b/Documentation/RCU/checklist.txt
@@ -365,3 +365,26 @@ over a rather long period of time, but improvements are always welcome!
 	and the compiler to freely reorder code into and out of RCU
 	read-side critical sections.  It is the responsibility of the
 	RCU update-side primitives to deal with this.
+
+17.	Use CONFIG_PROVE_RCU, CONFIG_DEBUG_OBJECTS_RCU_HEAD, and
+	the __rcu sparse checks to validate your RCU code.  These
+	can help find problems as follows:
+
+	CONFIG_PROVE_RCU: check that accesses to RCU-protected data
+		structures are carried out under the proper RCU
+		read-side critical section, while holding the right
+		combination of locks, or whatever other conditions
+		are appropriate.
+
+	CONFIG_DEBUG_OBJECTS_RCU_HEAD: check that you don't pass the
+		same object to call_rcu() (or friends) before an RCU
+		grace period has elapsed since the last time that you
+		passed that same object to call_rcu() (or friends).
+
+	__rcu sparse checks: tag the pointer to the RCU-protected data
+		structure with __rcu, and sparse will warn you if you
+		access that pointer without the services of one of the
+		variants of rcu_dereference().
+
+	These debugging aids can help you find problems that are
+	otherwise extremely difficult to spot.
