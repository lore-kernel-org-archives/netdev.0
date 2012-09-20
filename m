From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] tcp: use of undefined variable
Date: Thu, 20 Sep 2012 17:31:50 -0400 (EDT)
Message-ID: <20120920.173150.1701050165912197082.davem@davemloft.net>
References: <20120919144557.16956.11280.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab2ITVbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 17:31:52 -0400
In-Reply-To: <20120919144557.16956.11280.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Wed, 19 Sep 2012 15:46:06 +0100

> From: Alan Cox <alan@linux.intel.com>
> 
> Both tcp_timewait_state_process and tcp_check_req use the same basic
> construct of
> 
> 	struct tcp_options received tmp_opt;
> 	tmp_opt.saw_tstamp = 0;
> 
> then call
> 
> 	tcp_parse_options
> 
> However if they are fed a frame containing a TCP_SACK then tbe code
> behaviour is undefined because opt_rx->sack_ok is undefined data.
> 
> This ought to be documented if it is intentional.
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied to net-next, except I took this hunk out:

> @@ -96,6 +98,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
>  	bool paws_reject = false;
>  
>  	tmp_opt.saw_tstamp = 0;
> +
>  	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
>  		tcp_parse_options(skb, &tmp_opt, &hash_location, 0, NULL);
>  

Since it's unrelated to your change, and if you were going to do this in
tcp_timewait_state_process() you should do it in tcp_check_req() as well
since the code is identical.

Longer term maybe we probably should add a
tcp_minisock_parse_options() that elides TCP_SACK and other bits these
cases do not want.

Thanks Alan.
