From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH] devinet: inetdev_init out label moved after RCU assignment
Date: Fri, 5 Jan 2007 12:19:10 +0100
Message-ID: <20070105111910.GA3650@ff.dom.local>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104.123333.91315611.davem@davemloft.net> <20070105063844.GA1675@ff.dom.local> <20070105093846.GA21000@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dlstevens@us.ibm.com,
	greearb@candelatech.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:39491 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161060AbXAELR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jan 2007 06:17:29 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20070105093846.GA21000@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 05, 2007 at 08:38:47PM +1100, Herbert Xu wrote:
> On Fri, Jan 05, 2007 at 07:38:44AM +0100, Jarek Poplawski wrote:
> > 
> > I'd only suggest to change "goto out;" to
> > "return NULL;" at the end of inetdev_init because
> > now RCU is engaged unnecessarily.
> 
> I agree.  The RCU assignment should come before the out label.
> Can you send a patch?

Why me? (I didn't spoil this!)

Cheers,
Jarek P.

PS: should be applied after David's Stevens patch from 2007.01.04
---

Subject: [PATCH] devinet: inetdev_init out label moved after RCU assignment

inetdev_init out label moved after RCU assignment
(final suggestion by Herbert Xu)

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp linux-2.6.20-rc3-/net/ipv4/devinet.c linux-2.6.20-rc3/net/ipv4/devinet.c
--- linux-2.6.20-rc3-/net/ipv4/devinet.c	2007-01-05 11:53:16.000000000 +0100
+++ linux-2.6.20-rc3/net/ipv4/devinet.c	2007-01-05 11:55:32.000000000 +0100
@@ -174,9 +174,10 @@ struct in_device *inetdev_init(struct ne
 	ip_mc_init_dev(in_dev);
 	if (dev->flags & IFF_UP)
 		ip_mc_up(in_dev);
-out:
+
 	/* we can receive as soon as ip_ptr is set -- do this last */
 	rcu_assign_pointer(dev->ip_ptr, in_dev);
+out:
 	return in_dev;
 out_kfree:
 	kfree(in_dev);
