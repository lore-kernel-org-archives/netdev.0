From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Tue, 18 Aug 2009 07:54:25 -0400
Message-ID: <4A8A9671.8060002@myri.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>	<4A7C9A14.7070600@inria.fr>	<20090807175112.a1f57407.billfink@mindspring.com>	<4A7CCEFC.7020308@myri.com>	<20090807213557.d0faec23.billfink@mindspring.com>	<4A7D5CA4.3030307@myri.com>	<20090808112636.GB18518@localhost.localdomain>	<4A7DC230.6060206@myri.com>	<20090808183251.GA23300@localhost.localdomain>	<20090811033210.6b422ed1.billfink@mindspring.com>	<F169D4F5E1F1974DBFAFABF47F60C10A36523146@orsmsx507.amr.corp.intel.com>	<20090812003824.26c9c8fb.billfink@mindspring.com>	<20090814163155.968872fe.billfink@mindspring.com>	<20090817095302.0c41ef68@jbarnes-g45> <20090818030718.aef199f4.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1913 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751167AbZHRLyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 07:54:47 -0400
In-Reply-To: <20090818030718.aef199f4.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:

> <         Latency: 0, Cache Line Size: 64 bytes

<...>

>>       Latency: 0, Cache Line Size: 256 bytes


A cache line size of 256 clearly seems wrong for a Xeon.  I assume all
devices on the SuperMicro show the same value?

> Interestingly, the "WC Enabled" is only indicated on the first two

The WC is probably a red herring.

What does ethtool -S show for the DMA write bandwidth of the
NICs on the SuperMicro?

These values are obtained serially, as the driver resets
the NIC (reset happens at load time, and ifconfig up),
so they could easily sum to more than the memory bandwidth
of the system.  But it would be good to check for any anomalies.

I can send you a pointer to a tool we use internally, which loads
some custom firmware on the NIC, and can exercise the DMA engines
on all the NICs in parallel.  This would give an idea of the
aggregate DMA bandwidth available on the system.  Let me know
if you're interested.

Drew
