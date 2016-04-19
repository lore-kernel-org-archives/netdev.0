From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH net-next 0/8] Handle multiple received packets at
 each stage
Date: Tue, 19 Apr 2016 21:11:07 +0200
Message-ID: <20160419211107.486a3264@redhat.com>
References: <5716338E.4050003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	<linux-net-drivers@solarflare.com>, brouer@redhat.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932687AbcDSTLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 15:11:14 -0400
In-Reply-To: <5716338E.4050003@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Apr 2016 14:33:02 +0100
Edward Cree <ecree@solarflare.com> wrote:

> Earlier discussions on this list[1] suggested that having multiple packets
> traverse the network stack together (rather than calling the stack for each
> packet singly) could improve performance through better cache locality.
> This patch series is an attempt to implement this by having drivers pass an
> SKB list to the stack at the end of the NAPI poll.  The stack then attempts
> to keep the list together, only splitting it when either packets need to be
> treated differently, or the next layer of the stack is not list-aware.
> 
> The first two patches simply place received packets on a list during the
> event processing loop on the sfc EF10 architecture, then call the normal
> stack for each packet singly at the end of the NAPI poll.
> The remaining patches extend the 'listified' processing as far as the IP
> receive handler.
> 
> Packet rate was tested with NetPerf UDP_STREAM, with 10 streams of 1-byte
> packets, and the process and interrupt pinned to a single core on the RX
> side.
> The NIC was a 40G Solarflare 7x42Q; the CPU was a Xeon E3-1220V2 @ 3.10GHz.
> Baseline:      5.07Mpps
> after patch 2: 5.59Mpps (10.2% above baseline)
> after patch 8: 6.44Mpps (25.6% above baseline)

Quite impressive!  Thank you Edward, for working on this.  It is nice
to see that doing this actually gives a nice performance boost, it was
mostly a theory of mine in [1].

(p.s. I'm currently a bit busy at MM-summit, but try to follow the
thread.  I want to try out your patchset once I return home again...)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[1] http://thread.gmane.org/gmane.linux.network/395502
