From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: seeing strange values for tcp sk_rmem_alloc
Date: Tue, 01 Dec 2009 11:28:50 -0600
Message-ID: <4B155252.1040604@nortel.com>
References: <4B15416A.2060202@nortel.com> <4B154B29.1030807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:54724 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402AbZLARbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 12:31:15 -0500
In-Reply-To: <4B154B29.1030807@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2009 10:58 AM, Eric Dumazet wrote:

> Me wondering why you think sk_rmem_alloc is about TX side.
> Its used in RX path. rmem means ReadMemory.

Yep, I realize this.

> You can send 1 Gbytes of data, and sk_rmem_alloc doesnt change, if your
> TCP stream is unidirectionnal.
> 
> sk_rmem_alloc grows when skb are queued into receive queue
> sk_rmem_alloc shrinks when application reads this receive queue.

I realize this.  I sent the data from a socket to itself.  It could just
as easily be done with two tcp sockets.  The important thing is that I
control both the tx and rx sides, so I know how much data should be
present in the rx queue at any point in time.

The part that surprised me was that I could send multiple chunks of data
without sk_rmem_alloc changing on the socket to which the data was being
sent.  Then it would jump up by a large amount (up to 20K) all at once.

I'm starting to suspect that the discrepency might have something to do
with the skb_copy_datagram_iovec() call in tcp_data_queue(), and how
skb_set_owner_r() is only called if "eaten" is <= 0.  This could be
totally off-base though.

Chris
