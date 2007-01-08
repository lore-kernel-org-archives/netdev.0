From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Mon, 8 Jan 2007 07:53:46 +0100
Message-ID: <20070108065346.GA1665@ff.dom.local>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104.123333.91315611.davem@davemloft.net> <459EB627.5040606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	dlstevens@us.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:35242 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751463AbXAHGv5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 01:51:57 -0500
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <459EB627.5040606@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 05, 2007 at 12:33:43PM -0800, Ben Greear wrote:
...
> So, I do believe this was the problem we were hitting, and it seems fixed.

Congratulations!

But I can see one strange thing in vlan.c:

/* Must be invoked with RCU read lock (no preempt) */
static struct vlan_group *__vlan_find_group(int real_dev_ifindex)
...
 * Must be invoked with RCU read lock (no preempt)
 */
struct net_device *__find_vlan_dev(struct net_device *real_dev,
...

But later in this file no sign of disabling preemption
for these calls and for hlist_add_head_rcu and hlist_del_rcu.

I can't imagine how this works?

Jarek P. 
