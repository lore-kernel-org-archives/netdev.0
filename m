From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH net-next] tcp: avoid tx starvation by SYNACK packets
Date: Fri, 1 Jun 2012 09:36:12 +0200
Message-ID: <201206010939.22620.hans.schillstrom@ericsson.com>
References: <1338501397.2760.1395.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:51954 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757922Ab2FAHja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 03:39:30 -0400
In-Reply-To: <1338501397.2760.1395.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 31 May 2012 23:56:37 Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> pfifo_fast being the default Qdisc, its pretty easy to fill it with
> SYNACK (small) packets while host is under SYNFLOOD attack.
> 
> Packets of established TCP sessions are dropped and host appears almost
> dead.
> 
> Avoid this problem assigning TC_PRIO_FILLER priority to SYNACK
> generated in SYNCOOKIE mode, so that these packets are enqueued into
> pfifo_fast band 2.
> 
> Other packets, queued to band 0 or 1 are dequeued before any SYNACK
> packets waiting in band 2.
> 
Thanks Eric,
the patch is in under test now.

-- 
Regards
Hans Schillstrom
