From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 14 Jun 2007 09:51:19 +0800
Message-ID: <1181785879.4758.107.camel@debian.sh.intel.com>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com> <466FD638.4070907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29699 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756131AbXFNBwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 21:52:43 -0400
In-Reply-To: <466FD638.4070907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-13 at 13:34 +0200, Patrick McHardy wrote:
> > The key argument for Jamal's solution is the NIC will send out 32
> > packets in the full PHL in a reasonably short time (a few microsecs
> per
> > Jamal's calculation). But for wireless, the PHL hardware has low
> > probability to seize the wireless medium when there are full of high
> > priority frames in the air. That is, the chance for transmission in
> PHL
> > and PHH is not equal. Queuing packets in software will starve high
> > priority packets than putting them to PHH as early as possible.
> 
> 
> Well, the key result of our discussion was that it makes no difference
> wrt. queuing behaviour if the queue wakeup strategy is suitable chosen
> for the specific queueing discipline, but it might add some overhead. 

My point is the overhead is hugh for the wireless case which causes it
unacceptable. Given the above example in wireless medium, which queue
wakeup strategy will you choose? I guess it might be the "not stop tx
ring + requeue"? If this is selected, when there is a low priority
packet coming (PHL is full), the Qdisc will keep dequeue and requeue for
the same packet for a long time (given the fact of wireless medium) and
chew tons of CPU. We met this problem before in our driver and this (not
stop tx ring + requeue) is not a good thing to do.

Thanks,
-yi
