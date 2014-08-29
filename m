From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] pktgen: add flag NO_TIMESTAMP to disable
 timestamping
Date: Fri, 29 Aug 2014 09:17:06 -0700
Message-ID: <1409329026.3173.93.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140828161447.6652.59388.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	Robert Olsson <robert@herjulf.se>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:60929 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbaH2QRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 12:17:08 -0400
Received: by mail-pd0-f178.google.com with SMTP id y13so737474pdi.9
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 09:17:07 -0700 (PDT)
In-Reply-To: <20140828161447.6652.59388.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-28 at 18:14 +0200, Jesper Dangaard Brouer wrote:
> Then testing the TX limits of the stack, then it is useful to
> be-able to disable the do_gettimeofday() timetamping on every packet.
> 
> This implements a pktgen flag NO_TIMESTAMP which will disable this
> call to do_gettimeofday().
> 
> The performance change on (my system E5-2695) with skb_clone=0, goes
> from TX 2,423,751 pps to 2,567,165 pps with flag NO_TIMESTAMP. Thus,
> the cost of do_gettimeofday() or saving is approx 23 nanosec.

I guess using local_clock() would provide an accurate and less expensive
timestamp, if a timestamp is needed.
