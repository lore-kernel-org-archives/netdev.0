From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe question
Date: Sun, 29 Nov 2009 00:18:56 -0800 (PST)
Message-ID: <20091129.001856.236847721.davem@davemloft.net>
References: <4B0BADA6.7080602@gmail.com>
	<1259057164.2631.36.camel@ppwaskie-mobl2>
	<4B0BDC24.1060401@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, eric.dumazet@gmail.com,
	robert@herjulf.net, hawk@diku.dk, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751017AbZK2ISw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 03:18:52 -0500
In-Reply-To: <4B0BDC24.1060401@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Tue, 24 Nov 2009 13:14:12 +0000

> Believe the below patch will break DCB and FCoE though, both features
> have the potential to set real_num_tx_queues to greater then the
> number of CPUs.  This could result in real_num_tx_queues >
> num_tx_queues.
> 
> The current solution isn't that great though, maybe we should set to
> the minimum of MAX_TX_QUEUES and num_possible_cpus() * 2 + 8.
> 
> That should cover the maximum possible queues for DCB, FCoE and their
> combinations.
> 
> general multiq = num_possible_cpus()
> DCB = 8 tx queue's
> FCoE = 2*num_possible_cpus()
> FCoE + DCB = 8 tx queues + num_possible_cpus

Eric, I'm tossing your patch because of this problem, just FYI.
