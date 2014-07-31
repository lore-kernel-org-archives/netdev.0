From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/5] net-timestamp: additional sw tstamps
 and
Date: Thu, 31 Jul 2014 13:43:30 -0700 (PDT)
Message-ID: <20140731.134330.1615160836103431950.davem@davemloft.net>
References: <1406735328-7520-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaGaUnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 16:43:31 -0400
In-Reply-To: <1406735328-7520-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed, 30 Jul 2014 11:48:43 -0400

> Extend socket tx timestamping:
> - allow multiple types of software timestamps aside from send (1)
> - add software timestamp on tc enqueue (3)
> - add software timestamp for TCP (4)
> - add software timestamp for TCP on ACK (5)
> 
> The sk_flags option space is nearly exhausted. Also move the
> many timestamp options to a new sk->sk_tstamps (2).
> 
> The patchset extends Linux tx timestamping to monitoring of latency
> incurred within the kernel stack and to protocols embedded in TCP.
> Complex kernel setups may have multiple layers of queueing, including
> multiple instances of traffic shaping, and many classes per layer.
> Many applications embed discrete payloads into TCP bytestreams for
> reliability, flow control, etcetera. Detecting application tail
> latency in such scenarios relies on identifying the exact queue
> responsible if on the host, or the network latency if otherwise.

I'm mostly fine with this patchset, the only major blocker is the bit
that changes TCP segmenting behavior when timestamps are enabled.  I
really don't want to see us doing that, because that makes the
timestamps non-passive.

Please work towards a solution to that problem and also fixup the
minor naming et al. issues I brought up too.

Thanks.
