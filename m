From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: Performance fix for process_backlog
Date: Mon, 30 Jun 2014 12:28:34 -0700
Message-ID: <1404156514.15139.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1406300949290.5624@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:60705 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757014AbaF3T2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 15:28:38 -0400
Received: by mail-we0-f172.google.com with SMTP id u57so8588626wes.3
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 12:28:37 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406300949290.5624@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-30 at 09:50 -0700, Tom Herbert wrote:
> In process_backlog the input_pkt_queue is only checked once for new
> packets and quota is artificially reduced to reflect precisely the
> number of packets on the input_pkt_queue so that the loop exits
> appropriately.
> 
> This patches changes the behavior to be more straightforward and
> less convoluted. Packets are processed until either the quota
> is met or there are no more packets to process.
> 
> This patch seems to provide a small, but noticeable performance
> improvement. The performance improvement is a result of staying
> in the process_backlog loop longer which can reduce number of IPI's.

Yes, this is likely the fact that napi->state is cleared at the very end
of the run.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Tom !
