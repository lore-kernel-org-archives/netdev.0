From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 13 Jun 2007 13:56:08 +0800
Message-ID: <1181714168.4758.57.camel@debian.sh.intel.com>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57563 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750770AbXFMF5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 01:57:23 -0400
In-Reply-To: <466F0D74.5030308@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-06-12 at 23:17 +0200, Patrick McHardy wrote:
> I've hacked up a
> small multiqueue simulator device and to my big surprise my testing
> showed that Jamal's suggestion of using a single queue state seems to
> work better than I expected. But I've been doing mostly testing of
> the device itself up to now with very simple traffic patterns (mostly
> just "flood all queues"), so I'll try to get some real results
> tomorrow. 

The key argument for Jamal's solution is the NIC will send out 32
packets in the full PHL in a reasonably short time (a few microsecs per
Jamal's calculation). But for wireless, the PHL hardware has low
probability to seize the wireless medium when there are full of high
priority frames in the air. That is, the chance for transmission in PHL
and PHH is not equal. Queuing packets in software will starve high
priority packets than putting them to PHH as early as possible.

Patrick, I don't think your testing considered about above scenario,
right?

Thanks,
-yi
