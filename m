From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] pktgen: restore nanosec delays
Date: Sat, 3 Oct 2009 21:16:20 -0700
Message-ID: <20091003211620.4ac469b6@nehalam>
References: <4AC737E6.1050809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58726 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750882AbZJDERD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Oct 2009 00:17:03 -0400
In-Reply-To: <4AC737E6.1050809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 03 Oct 2009 13:39:18 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Commit fd29cf72 (pktgen: convert to use ktime_t)
> inadvertantly converted "delay" parameter from nanosec to microsec.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> 
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index b694552..227ba31 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -964,7 +964,7 @@ static ssize_t pktgen_if_write(struct file *file,
>  		if (value == 0x7FFFFFFF)
>  			pkt_dev->delay = ULLONG_MAX;
>  		else
> -			pkt_dev->delay = (u64)value * NSEC_PER_USEC;
> +			pkt_dev->delay = (u64)value;

Is the cast really necessary?
