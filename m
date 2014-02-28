From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 net-next] tcp: switch rtt estimations to usec resolution
Date: Thu, 27 Feb 2014 21:20:25 -0800
Message-ID: <87fvn3dd9i.fsf@tassilo.jf.intel.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	<1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58569 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751342AbaB1FU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 00:20:27 -0500
In-Reply-To: <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Sun, 23 Feb 2014 10:50:58 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
>  
> -	rtt_update = tcp_ack_update_rtt(sk, flag, seq_rtt, sack_rtt);
> +	if (first_ackt.tv64) {
> +		ktime_t curt = ktime_get_real();

Sorry I'm late to the party. One problem is that if a system doesn't use
TSC for some reason this will be incredibly slow (unfortunately this
happens for various reasons). Perhaps we need a
ktime_get_real_but_use_jiffies_if_slow() or somesuch.

-andi

-- 
ak@linux.intel.com -- Speaking for myself only
