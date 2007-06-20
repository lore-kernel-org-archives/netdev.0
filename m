From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 20 Jun 2007 13:51:46 +0800
Message-ID: <1182318706.4092.255.camel@debian.sh.intel.com>
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
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57130 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756835AbXFTFxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 01:53:54 -0400
In-Reply-To: <1182269060.4968.45.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-06-19 at 12:04 -0400, jamal wrote:
> In the case of wireless, pick two numbers XHH and XHL with XHL < XHH.
> The timers would be similar in nature (THH > THL). All these variables
> are only valid if you shutdown the ring. 
> So in the case HL shuts down the ring, you fire THL. If either XHL
> packets are transmitted or THL expires, you netif_wake.
> Did that make sense? 

No, because this is over-engineered. Furthermore, don't you think the
algorithm is complicated and unnecessary (i.e. one timer per h/w queue)?
Do you think the driver maintainer will accept such kind of workaround
patch? You did too much to keep the Qdisc interface untouched!

Besides, the lower THL you choose, the more CPU time is wasted in busy
loop for the only PL case; the higher THL you choose, the slower the PH
packets will be sent out than expected (the driver doesn't fully utilize
the device function -- multiple rings, which conlicts with a device
driver's intention). You can never make a good trade off in this model.

I think I have fully understood you, but your point is invalid. The
Qdisc must be changed to have the hardware queue information to support
multiple hardware queues devices.

Thanks,
-yi
