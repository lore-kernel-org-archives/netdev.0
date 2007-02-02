From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Fri, 02 Feb 2007 11:46:08 -0800 (PST)
Message-ID: <20070202.114608.59498910.davem@davemloft.net>
References: <20070131.011629.84005028.yoshfuji@linux-ipv6.org>
	<20070131205443.GA12237@hmsreliant.homelinux.net>
	<20070202190634.GA29001@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, vladislav.yasevich@hp.com, sri@us.ibm.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33715
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423198AbXBBTqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 14:46:10 -0500
In-Reply-To: <20070202190634.GA29001@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 2 Feb 2007 14:06:34 -0500

> Ok, I'm still testing it, but heres a new patch for review.
> Significant changes include the addition of a
> CONFIG_IPV6_OPTIMISTIC_DAD option that is dependent on the inclusion
> of both IPPV6 and EXPERIMENTAL options, as well as a new method for
> redirecting packets from optimistic sources to incomplete neighbors
> by instead looking up a default router in ip6_dst_lookup_tail, as I
> described in my previous note.

This looks largely fine to me, but I wonder about one bit:

+
+	/*
+	 * Optimistic nodes need to join the anycast address
+	 * right away
+	 */
+	if (ifp->flags & IFA_F_OPTIMISTIC)
+		addrconf_join_anycast(ifp);
+

If something can clear that bit during the DAD, we won't
call addrconf_leave_anycast() later.  Can that happen?
