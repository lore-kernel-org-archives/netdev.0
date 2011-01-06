From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: IP defragmentation must be ECN aware
Date: Thu, 06 Jan 2011 11:21:03 -0800 (PST)
Message-ID: <20110106.112103.59674935.davem@davemloft.net>
References: <1294249261.10633.54.camel@edumazet-laptop>
	<20110105094830.63a68230@nehalam>
	<1294249975.10633.74.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38472
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751404Ab1AFTUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 14:20:31 -0500
In-Reply-To: <1294249975.10633.74.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Jan 2011 18:52:55 +0100

> [PATCH v2] ipv4: IP defragmentation must be ECN aware
> 
> RFC3168 (The Addition of Explicit Congestion Notification to IP)
> states :
> 
> 5.3.  Fragmentation
> 
>    ECN-capable packets MAY have the DF (Don't Fragment) bit set.
>    Reassembly of a fragmented packet MUST NOT lose indications of
>    congestion.  In other words, if any fragment of an IP packet to be
>    reassembled has the CE codepoint set, then one of two actions MUST be
>    taken:
> 
>       * Set the CE codepoint on the reassembled packet.  However, this
>         MUST NOT occur if any of the other fragments contributing to
>         this reassembly carries the Not-ECT codepoint.
> 
>       * The packet is dropped, instead of being reassembled, for any
>         other reason.
> 
> This patch implements this requirement for IPv4, choosing the first
> action : 
> 
> If one fragment had NO-ECT codepoint
>         reassembled frame has NO-ECT
> ElIf one fragment had CE codepoint
>         reassembled frame has CE
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot Eric.
