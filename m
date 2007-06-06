From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 16:52:15 -0700 (PDT)
Message-ID: <20070606.165215.38711917.davem@davemloft.net>
References: <1181168020.4064.46.camel@localhost>
	<20070606.153530.48530367.davem@davemloft.net>
	<1181172766.4064.83.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60859
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935187AbXFFXv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 19:51:59 -0400
In-Reply-To: <1181172766.4064.83.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 06 Jun 2007 19:32:46 -0400

> On Wed, 2007-06-06 at 15:35 -0700, David Miller wrote:
> > With the above for transmit, and having N "struct napi_struct"
> > instances for MSI-X directed RX queues, we'll have no problem keeping
> > a 10gbit (or even faster) port completely full with lots of cpu to
> > spare on multi-core boxes.
> > 
> 
> RX queues - yes, I can see;  TX queues, it doesnt make sense to put
> different rings on different CPUs.

For the locking is makes a ton of sense.

If you have sendmsg() calls going on N cpus, would you rather
they:

1) All queue up to the single netdev->tx_lock

or

2) All take local per-hw-queue locks

to transmit the data they are sending?

I thought this was obvious... guess not :-)
