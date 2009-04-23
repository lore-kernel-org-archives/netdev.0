From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: about latencies
Date: Thu, 23 Apr 2009 16:01:06 -0700
Message-ID: <1240527666.8857.8.camel@HP1>
References: <49F0E579.5030200@cosmosbay.com>
 <alpine.WNT.2.00.0904231520300.5352@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"Christoph Lameter" <cl@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Ben Hutchings" <bhutchings@solarflare.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4448 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753617AbZDWXGy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 19:06:54 -0400
In-Reply-To: <alpine.WNT.2.00.0904231520300.5352@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2009-04-23 at 15:34 -0700, Brandeburg, Jesse wrote:
> On Thu, 23 Apr 2009, Eric Dumazet wrote:
> 
> > 3) changing bnx2_poll_work() to first call bnx2_rx_int(), then bnx2_tx_int() to consume tx.
> 
> at least all of the intel drivers that have a single vector (function) 
> handling interrupts, always call tx clean first so that any tx buffers are 
> free to be used immediately because the NAPI calls can generate tx traffic 
> (acks in the case of tcp and full routed packet transmits in the case of 
> forwarding)
> 

Are you talking about freeing the tx buffers in the tx ring to make room
for more tx packets?  As long as the tx ring is not previously full and
is now completely free and idle, it doesn't matter too much when we free
the tx buffers in the tx ring, does it?


