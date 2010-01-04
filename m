From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH 1/3] netem/iproute2 solving correlated loss issue
Date: Sun, 03 Jan 2010 21:50:20 -0800 (PST)
Message-ID: <20100103.215020.190259610.davem@davemloft.net>
References: <4B3A5F84.4050603@yahoo.it>
	<4B3A5FF5.30602@yahoo.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fabio.ludovici@yahoo.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48504
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752909Ab0ADFuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:50:16 -0500
In-Reply-To: <4B3A5FF5.30602@yahoo.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Ludovici <fabio.ludovici@yahoo.it>
Date: Tue, 29 Dec 2009 21:00:53 +0100

> enhances netem module as follows:
> 
> - add deterministic loss generation according to a pattern that can be
> - specified in a file in the iproute2 command line
> - new statistical models for generation of correlated loss (the existing
> - model does not work), including loss models commonly used in
> - literature (bernoulli, Gilbert, Gilbert Elliot) and the new GI
> - (General and Intuitive model)
> - enhanced logging functionality for loss events in dmesg
> 
> Signed-off-by: Stefano Salsano <stefano.salsano@uniroma2.it>
> Signed-off-by: Fabio Ludovici <fabio.ludovici@yahoo.it>
> ---
>  include/linux/pkt_sched.h |   33 ++++++
>  net/sched/sch_netem.c | 277
>  +++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 310 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index d51a2b3..b492fd3 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -466,6 +466,10 @@ enum
>      TCA_NETEM_DELAY_DIST,
>      TCA_NETEM_REORDER,
>      TCA_NETEM_CORRUPT,
> +    TCA_NETEM_LOSS_GI,
> +    TCA_NETEM_LOSS_GILBELL,
> +    TCA_NETEM_LOSS_PATTERN,
> +    TCA_NETEM_LOGGING,
>      __TCA_NETEM_MAX,

Mail client has turned tabs into spaces, corrupting the patch.

> +    __u32    p32;
> +    __u32    p23;
> +    __u32   p14;

Inconsistent formatting, probably also caused by your email
client.

> +        // GI loss model transition probabilities

Please no C++ style comments.

> +    u32 p13;
> +    u32 p31;
> +    u32 p23;
> +    u32 p32;
> +    u32 p14;
> +    // Gilbert and Gilbert-Elliot loss models parameters
> +    u32 p;
> +    u32 r;
> +    u32 h;
> +    u32 k;
> +    // Markov chain state for GI, Gilbert and Gilbert-Elliot models
> +    u8 chain_state;
> +    // Deterministic pattern parameters
> +    u16 pattern_length;        //deterministic loss length
> + u32 pattern_repetitions; //deterministic loss pattern repetitions
> +    u32 *kernel_pattern;         //deterministic loss pattern
> +    // Logging parameters and variables
> +    u8 logging_level;
> +    u32 num_of_drops;        //number of dropped packets
> + u32 num_of_transmissions; //number of correctly transmitted packets
> +    u32 pattern_counter;        //deterministic loss counter
> + u32 repetitions_done; //deterministic loss repetitions counter

Do you really need to bloat up this structure with such an
enormous number of new elements?

Stephen can you champion this work, it needs a lot of help?

Thanks.
