From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] NET: [UPDATED] Multiqueue network device support
	implementation.
Date: Thu, 12 Apr 2007 13:24:23 +0800
Message-ID: <1176355463.16123.243.camel@debian.sh.intel.com>
References: <D5C1322C3E673F459512FB59E0DDC32902A1A535@orsmsx414.amr.corp.intel.com>
	 <461D14E1.6020100@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48488 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422664AbXDLF0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 01:26:50 -0400
In-Reply-To: <461D14E1.6020100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-11 at 19:03 +0200, Patrick McHardy wrote:
> 
> You bring up a good point, it would be good to hear the opinion from
> one of the wireless people on this since they have their own
> multiqueue scheduler in the wireless-dev tree. 

The one in the wireless-dev is pretty much like this one. It existed
only because there was not such a multiqueue aware qdisc available at
that time.

The requirement for wireless is the same as the strict PRIO with an
addition that the dequeued SKB's corresponding NIC hardware queue must
be active (this is also true for other devices I think, otherwise it has
to be requeued which leads a busy or dead loop in the end). In other
words, the dequeue method should select the SKB with the highest
priority from all the ACTIVE hardware queues (not all queues). The
wireless hardware then schedules all the packets from its 4 hardware TX
queues based on the priority and network environment.

Thanks,
-yi
