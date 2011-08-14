From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Proportional Rate Reduction for TCP.
Date: Sat, 13 Aug 2011 22:05:25 -0700
Message-ID: <m262m0lh0q.fsf@firstfloor.org>
References: <1313134197-5082-1-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62247 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727Ab1HNFF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Aug 2011 01:05:28 -0400
In-Reply-To: <1313134197-5082-1-git-send-email-nanditad@google.com> (Nandita
	Dukkipati's message of "Fri, 12 Aug 2011 00:29:57 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nandita Dukkipati <nanditad@google.com> writes:
> +
> +	if (tcp_packets_in_flight(tp) > tp->snd_ssthresh) {
> +		if (WARN_ON(!tp->prr_cwnd))
> +			tp->prr_cwnd = 1;
> +		sndcnt = DIV_ROUND_UP(tp->prr_delivered * tp->snd_ssthresh,
> +				      tp->prr_cwnd) - tp->prr_out;
> +	} else {
> +		sndcnt = min_t(int, delta,
> +			       max_t(int, tp->prr_delivered -
> tp->prr_out,

u32s here? This will likely do bad things with large enough windows.

The rest looks good to me as code, but I don't claim to fully understand the 
algorithm. Perhaps a sysctl to turn it off and a linux mib counter when 
it triggers would be useful in addition.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
