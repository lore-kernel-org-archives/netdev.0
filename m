From: David Miller <davem@davemloft.net>
Subject: Re: auro deadlock
Date: Fri, 07 Jul 2006 12:09:36 -0700 (PDT)
Message-ID: <20060707.120936.98532669.davem@davemloft.net>
References: <20060707171916.GA16343@redhat.com>
	<1152295989.3111.116.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, akpm@osdl.org, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48094
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932265AbWGGTJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 15:09:05 -0400
To: arjan@infradead.org
In-Reply-To: <1152295989.3111.116.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arjan van de Ven <arjan@infradead.org>
Date: Fri, 07 Jul 2006 20:13:09 +0200

> Now a question for netdev: what is the interrupt-or-softirq rules for
> the sk_receive_queue.lock?
> 
> Anyway, the patch below fixes this deadlock; it may or may not be the
> correct solution depending on the netdev answer, but the deadlock is
> gone ;)

The lockdep fixes are starting to cause us to go in and start adding
hard IRQ protection to many socket layer objects and I want this
thinking to end quickly :)

The netlink wireless fix is another example of this, but I accept the
temporary fix for that one for the time being.

To reiterate, nothing socket or SKB level should be taking anything
deeper than software IRQ locking.

If drivers manage local SKB queues in hard IRQ context, they need to
use a seperate lockdep identifier for that queue's lock.
