From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Fri, 15 Jun 2007 09:27:06 +0800
Message-ID: <1181870826.4092.29.camel@debian.sh.intel.com>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com>
	 <1181737935.4050.87.camel@localhost>
	 <1181789064.4758.127.camel@debian.sh.intel.com>
	 <1181821707.4091.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50308 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751773AbXFOB2f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 21:28:35 -0400
In-Reply-To: <1181821707.4091.32.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-06-14 at 07:48 -0400, jamal wrote:
> I dont have much time to followup for sometime to come. I have left my
> answer above. To clarify, incase i wasnt clear, I am saying:
> a) It is better to have the driver change via some strategy of when to
> open the tx path than trying to be generic. This shifts the burden to
> the driver.
> b) given the behavior of wireless media (which is very different from
> wired ethernet media), you need a different strategy. In response to
> Guy's question, I gave the example of being able to use management
> frames to open up the tx path for VO (even when you dont know VO
> packets
> are sitting on the qdisc); alternatively you could use a timer etc.
> Theres many ways to skin the cat (with apologies to cat
> lovers/owners).
> i.e you need to look at the media and be creative.
> Peters DCE for example could also be handled by having a specific
> strategy. 

OK. You tried so much to guess the traffic flow pattern in the low level
driver, which could be implemented straightforward in the Qdisc. The pro
is the Qdisc API is untouched. But the cons are:

1. driver becomes complicated (as it is too elaborate in the queue
wakeup strategies design)
2. duplicated code among drivers (otherwise you put all the queue
management logics in a new layer?)
3. it's not 100% accurate. there has to be some overhead, more or less
depends on the queue wakeup strategy the driver selected.

Time for voting?

Thanks,
-yi
