From: Rusty Russell <rusty@rustcorp.com.au>
Subject: csum offload and af_packet
Date: Mon, 11 Aug 2008 23:50:25 +1000
Message-ID: <200808112350.25514.rusty@rustcorp.com.au>
References: <E1KSU3v-00037r-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: anthony@codemonkey.ws, netdev@vger.kernel.org, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33013 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751411AbYHKNyU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 09:54:20 -0400
In-Reply-To: <E1KSU3v-00037r-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 11 August 2008 19:51:39 Herbert Xu wrote:
> Rusty Russell <rusty@rustcorp.com.au> wrote:
> > add an "else if (skb->ip_summed == CHECKSUM_PARTIAL)" case...
>
> If you're going to hack the guest kernel, then you might as well
> fix the guest DHCP client.  However, we should default checksum
> offload to off until we know that the client is capable of handling
> it (to handle guests that haven't been fixed).

I think this is deeper than that.  This case is actually unusual, in that the 
packet really does arrive with a partial csum.  But usually, we're exposing 
an internal detail of our stack at this point.  Seems like we shouldn't if we 
know the user can't deal with it.  dhcpd just makes this case less academic.

> One easy way of doing this is to hook up the rx checksum offload
> option in the guest with the tx offload option in the host.  In
> other words, when rx offload is enabled in the guest we enable
> tx offload in the host, and disable it vice versa.

We can trivially disable it in the guest or host; that's not the problem.  We 
can even disable csum offload just for UDP in the host.  But should we 
really?

Rusty.
