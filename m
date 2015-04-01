From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next PATCH] pktgen: add flag NO_TIMESTAMP to disable timestamping
Date: Wed, 01 Apr 2015 09:48:56 -0700
Message-ID: <551C2178.9070000@candelatech.com>
References: <20140828161447.6652.59388.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.se>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:50252 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbbDAQs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 12:48:57 -0400
In-Reply-To: <20140828161447.6652.59388.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/2014 09:14 AM, Jesper Dangaard Brouer wrote:
> Then testing the TX limits of the stack, then it is useful to
> be-able to disable the do_gettimeofday() timetamping on every packet.
> 
> This implements a pktgen flag NO_TIMESTAMP which will disable this
> call to do_gettimeofday().
> 
> The performance change on (my system E5-2695) with skb_clone=0, goes
> from TX 2,423,751 pps to 2,567,165 pps with flag NO_TIMESTAMP. Thus,
> the cost of do_gettimeofday() or saving is approx 23 nanosec.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

> +		else if (strcmp(f, "NO_TIMESTAMP") == 0)
> +			pkt_dev->flags |= F_NO_TIMESTAMP;
> +

While porting pktgen changes into my own modified pktgen logic, I noticed
that there is no handling for !NO_TIMESTAMP, so it seems you cannot
disable this once it is enabled?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
