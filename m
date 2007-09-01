From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 1/2]: [NET_SCHED]: Make all rate based scheduler work
 with TSO.
Date: Sat, 1 Sep 2007 23:38:23 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0709012325080.29796@ask.diku.dk>
References: <1188562975.18622.11.camel@localhost.localdomain>
 <46D9103B.7090905@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: jdb@comx.dk, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:40983 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756169AbXIAWE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Sep 2007 18:04:57 -0400
In-Reply-To: <46D9103B.7090905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sat, 1 Sep 2007, Patrick McHardy wrote:

> Jesper Dangaard Brouer wrote:
>> commit 6fdc0f061be94f5e297650961360fb7a9d1cc85d
>> Author: Jesper Dangaard Brouer <hawk@comx.dk>
>> Date:   Thu Aug 30 17:53:42 2007 +0200
>> 
>> [NET_SCHED]: Make all rate based scheduler work with TSO.
>> 
>> Change L2T (length to time) macros, in all rate based schedulers, to
>> call a common function qdisc_l2t() that does the rate table lookup.
>> This function handles if the packet size lookup is larger than the
>> rate table, which often occurs with TSO enabled.
>
>
> It still won't work properly with TSO (TBF for example already drops
> oversized packets during ->enqueue), but its a good cleanup anyway.

Then lets call it a cleanup of the L2T macros.  In the next step we will 
fix the different schedulers, to use the ability to lookup larger sized 
packets. (I did notice the TBF scheduler would drop oversized packets).


>> +#define L2T(p,L)   ((p)->tcfp_R_tab, L)
>> +#define L2T_P(p,L) ((p)->tcfp_P_tab, L)
>
>
> I'd prefer to get rid of these L2T macros completely.

Lets take it one step at a time, but I agree.


Will you ack the patch as a cleanup?

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
