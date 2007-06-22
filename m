From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Fri, 22 Jun 2007 09:26:54 +0800
Message-ID: <1182475614.30969.102.camel@debian.sh.intel.com>
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
	 <1182219120.4092.143.camel@debian.sh.intel.com>
	 <1182269060.4968.45.camel@localhost>
	 <1182318706.4092.255.camel@debian.sh.intel.com>
	 <1182440388.5017.31.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1272 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751200AbXFVB3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 21:29:15 -0400
In-Reply-To: <1182440388.5017.31.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-06-21 at 11:39 -0400, jamal wrote:
> I gave you two opportunities to bail out of this discussion, i am gonna
> take that your rejection to that offer implies you my friend wants to
> get to the bottom of this i.e you are on a mission to find the truth.
> So lets continue this.

It sounds stupid I'm still trying to convince you why we need multiqueue
support in Qdisc when everybody else are already working on the code,
fixing bugs and preparing for merge. The only reason I keep the
conversation is that I think you _might_ have some really good points
that buried under everybody else's positive support for multiqueue. But
with the conversation goes on, it turns out not the truth. Let me snip
the nonsense part below and only focus on technical.

> > Besides, the lower THL you choose, the more CPU time is wasted in busy
> > loop for the only PL case; 
> 
> Your choice of THL and THH has nothing to do with what i am proposing.
> I am not proposing you even touch that. What numbers do you have today?

We don't have THL and THH in our driver. They are what you suggested.
The queue wakeup number is 1/4 of the ring size.

> What i am saying is you use _some_ value for opening up the driver; some
> enlightened drivers such as the tg3 (and the e1000 - for which i
> unashamedly take credit) do have such parametrization. This has already
> been proven to be valuable.
> 
> The timer fires only if a ring shuts down the interface. Where is the
> busy loop? If packets go out, there is no timer.

The busy loop happens in the period after the ring is shut down and
before it is opened again. During this period, the Qdisc will keep
dequeuing and requeuing PL packets in the Tx SoftIRQ, where the busy
loop happens.

> > the higher THL you choose, the slower the PH
> > packets will be sent out than expected (the driver doesn't fully utilize
> > the device function -- multiple rings, 
> 
> I dont think you understood: Whatever value you choose for THL and THH
> today, keep those. OTOH, the wake threshold is what i was refering to.

I don't even care about the threshold. Even you set it to 1, there is
still busy loop during the period before this first packet is sent out
in the air. But you cannot ignore this small time, because it could be
longer when the wireless medium is congested with high prio packets.

Thanks,
-yi
