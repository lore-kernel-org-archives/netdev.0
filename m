From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [RFC net-next 0/4] gianfar: Use separate NAPI for Tx
 confirmation processing
Date: Wed, 8 Aug 2012 12:24:23 -0400
Message-ID: <20120808162423.GC11043@windriver.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:64056 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295Ab2HHQY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 12:24:27 -0400
Content-Disposition: inline
In-Reply-To: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[[RFC net-next 0/4] gianfar: Use separate NAPI for Tx confirmation processing] On 08/08/2012 (Wed 15:26) Claudiu Manoil wrote:

> Hi all,
> This set of patches basically splits the existing napi poll routine into
> two separate napi functions, one for Rx processing (triggered by frame
> receive interrupts only) and one for the Tx confirmation path processing
> (triggerred by Tx confirmation interrupts only). The polling algorithm
> behind remains much the same.
> 
> Important throughput improvements have been noted on low power boards with
> this set of changes.
> For instance, for the following netperf test:
> netperf -l 20 -cC -H 192.168.10.1 -t TCP_STREAM -- -m 1500
> yields a throughput gain from oscilating ~500-~700 Mbps to steady ~940 Mbps,
> (if the Rx/Tx paths are processed on different cores), w/ no increase in CPU%,
> on a p1020rdb - 2 core machine featuring etsec2.0 (Multi-Queue Multi-Group
> driver mode).

It would be interesting to know more about what was causing that large
an oscillation -- presumably you will have it reappear once one core
becomes 100% utilized.  Also, any thoughts on how the change will change
performance on an older low power single core gianfar system (e.g.  83xx)?

P.
--

> 
> Also, this change, which should ballance Rx and Tx processing, proves to
> be effective against Rx busy interrupt occurrences.
> 
> Thanks for your review.
> Claudiu
> 
> 
> Claudiu Manoil (4):
>   gianfar: Remove redundant programming of [rt]xic registers
>   gianfar: Clear ievent from interrupt handler for [RT]x int
>   gianfar: Separate out the Rx and Tx coalescing functions
>   gianfar: Use separate NAPIs for Tx and Rx processing
> 
>  drivers/net/ethernet/freescale/gianfar.c |  220 +++++++++++++++++++++--------
>  drivers/net/ethernet/freescale/gianfar.h |   16 ++-
>  2 files changed, 171 insertions(+), 65 deletions(-)
> 
> 
