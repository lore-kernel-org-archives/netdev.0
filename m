From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 19 Jun 2007 10:12:00 +0800
Message-ID: <1182219120.4092.143.camel@debian.sh.intel.com>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com>
	 <1181737935.4050.87.camel@localhost>
	 <1181789064.4758.127.camel@debian.sh.intel.com>
	 <1181821707.4091.32.camel@localhost>
	 <1181870826.4092.29.camel@debian.sh.intel.com>
	 <1181904575.4102.31.camel@localhost>
	 <1182129521.4092.77.camel@debian.sh.intel.com>
	 <1182179770.4063.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38523 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760707AbXFSCOD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2007 22:14:03 -0400
In-Reply-To: <1182179770.4063.26.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-06-18 at 11:16 -0400, jamal wrote:
> > in your model how to
> > define the queue wakeup strategy in the driver to deal with the PHL full
> > situation? Consider about 1) both high prio and low prio packets could
> > come (you cannot predict it beforehand) 
> 
> I am assuming by "come" you mean from the stack (example an ssh packet)
> as opposed from the outside.

Right.

> > 2) the time for PHL to send out
> > a packet to the wireless medium is relative long (given the medium is
> > congested). If you can resolve it in an elegant way, I'm all ears.
> 
> Congestion periods are the only time any of this stuff makes sense.

We are talking about the period from the time PHL is full to the time it
can accept more packets again. How to design the queue wakeup policy in
this period is the question.

> Ok, so let me repeat what i said earlier:
>
> Once a packet is in the DMA ring, we dont take it out. If a high prio
> packet is blocking a low prio one, i consider that to be fine. If otoh,
> you receive a management detail from the AP indicating that LP has its
> priority bumped or HP has its prio lowered, then by all means use that
> info to open up the path again. Again, that is an example, you could use
> that or schemes (refer to my expression on cats earlier).

No, this is not my question. Mine was much simpler. We don't need to
consider the wireless dynamic priority change case at this time. Just
tell me what you suppose the driver to do (stop|start queue) when the
hardware PHL is full but PHH is empty?

Thanks,
-yi
