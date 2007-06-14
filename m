From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 14 Jun 2007 10:44:24 +0800
Message-ID: <1181789064.4758.127.camel@debian.sh.intel.com>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com>
	 <1181737935.4050.87.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44670 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751172AbXFNCpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 22:45:46 -0400
In-Reply-To: <1181737935.4050.87.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-13 at 08:32 -0400, jamal wrote:
> The key arguement i make (from day one actually) is to leave the
> majority of the work to the driver.

But it seems not feasible the Qdisc needs to know nothing about the
hardware rings.

> My view of wireless WMM etc is it is a different media behavior
> (compared to wired ethernet) which means a different view of strategy
> for when it opens the valve to allow in more packets. 802.11 media has
> embedded signalling which is usable. Guy Cohen gave a good use case
> which i responded to. Do you wanna look at that and respond? 

The key to support multi-ring hardware for software is to put packets
into hardware as much/early as possible. Guy gave a good VO vs. BK
example. To achieve this in your model, you have to keep the TX ring
running (in the case of PHL full) and requeue. But when there are only
BK packets coming, you do want to stop the ring, right? AFAICS, the
driver is not the best place to make the decision (it only knows the
current and previous packets, but not the _next_), the Qdisc is the best
place.

Thanks,
-yi
