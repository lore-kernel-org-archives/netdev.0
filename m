From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2]: [NET_SCHED]: Make all rate based scheduler work
 with	TSO.
Date: Sat, 01 Sep 2007 09:09:47 +0200
Message-ID: <46D9103B.7090905@trash.net>
References: <1188562975.18622.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48285 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbXIAHLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 03:11:20 -0400
In-Reply-To: <1188562975.18622.11.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Dangaard Brouer wrote:
> commit 6fdc0f061be94f5e297650961360fb7a9d1cc85d
> Author: Jesper Dangaard Brouer <hawk@comx.dk>
> Date:   Thu Aug 30 17:53:42 2007 +0200
> 
>     [NET_SCHED]: Make all rate based scheduler work with TSO.
>     
>      Change L2T (length to time) macros, in all rate based schedulers, to
>      call a common function qdisc_l2t() that does the rate table lookup.
>      This function handles if the packet size lookup is larger than the
>      rate table, which often occurs with TSO enabled.


It still won't work properly with TSO (TBF for example already drops
oversized packets during ->enqueue), but its a good cleanup anyway.

 > +#define L2T(p,L)   ((p)->tcfp_R_tab, L)
 > +#define L2T_P(p,L) ((p)->tcfp_P_tab, L)


I'd prefer to get rid of these L2T macros completely.
