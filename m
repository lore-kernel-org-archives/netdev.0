From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 15:04:50 -0700 (PDT)
Message-ID: <20070612.150450.17595071.davem@davemloft.net>
References: <466F142C.4040109@garzik.org>
	<adazm347sdw.fsf@cisco.com>
	<466F174F.5090206@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, greearb@candelatech.com, netdev@vger.kernel.org,
	kaber@trash.net, hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51187
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755760AbXFLWEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 18:04:34 -0400
In-Reply-To: <466F174F.5090206@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 12 Jun 2007 17:59:43 -0400

> And where shall we put the configuration machinery, to support sub-queues?
> Shall we duplicate the existing configuration code for sub-queues?
> What will ifconfig/ip usage look like?
> How will it differ from configurating full net_devices, if you are 
> assigning the same types of parameters?

If you're asking about the virtualization scenerio, the
control node (dom0 or whatever) is the only entity which
can get at programming the filters and will set it up
properly based upon which parts of the physical device
are being exported to which guest nodes.

For the non-virtualized case, it's a good question.

But really the current hardware is just about simple queue steering,
and simple static DRR/WRED fairness algorithms applied to the queues
in hardware.

We don't need to add support for configuring anything fancy from the
start just to get something working.  Especially the important bits
such as the virtualization case and the interrupt and queue
distribution case on SMP.  The latter can even be configured
automatically by the driver, and that's in fact what I expect
drivers to do initially.

