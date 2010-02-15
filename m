From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v5 3/7] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Mon, 15 Feb 2010 13:48:42 +0100
Message-ID: <20100215124842.GF21783@one.firstfloor.org>
References: <4B793CAA.2030902@gmail.com> <4B793DFC.8070306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:60974 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab0BOMsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 07:48:46 -0500
Content-Disposition: inline
In-Reply-To: <4B793DFC.8070306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2010 at 07:28:44AM -0500, William Allen Simpson wrote:
> Harmonize tcp_v4_rcv() and tcp_v6_rcv() -- better document tcp doff
> and header length assumptions, and carefully compare implementations.
> 
> Reduces multiply/shifts, marginally improving speed.
> 
> Removes redundant tcp header length checks before checksumming.
> 
> Instead, assumes (and documents) that any backlog processing and
> transform policies will carefully preserve the header, and will
> ensure the socket buffer length remains >= the header size.

I reviewed the patch and it looks ok to me. As far as I can
see it's mostly manual CSE, no real behaviour change.

Normally it's customary to separate formatting changes from
real changes, but it was only in a few places and not too bad.

I didn't fully understand that new comment:

/* nf_reset(skb); in ip6_input.c ip6_input_finish() */

Overall you can add a 

Reviewed-by: Andi Kleen <andi@firstfloor.org>

-Andi
