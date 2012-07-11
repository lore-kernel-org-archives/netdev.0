From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v3 net-next] tcp: TCP Small Queues
Date: Wed, 11 Jul 2012 11:38:31 -0700
Message-ID: <m2r4sirvmg.fsf@firstfloor.org>
References: <1342021831.3265.8174.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nanditad@google.com,
	netdev@vger.kernel.org, codel@lists.bufferbloat.net,
	ncardwell@google.com, mattmathis@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57965 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755108Ab2GKSid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 14:38:33 -0400
In-Reply-To: <1342021831.3265.8174.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Wed, 11 Jul 2012 17:50:31 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> +
> +		if (!sock_owned_by_user(sk)) {
> +			if ((1 << sk->sk_state) &
> +			    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 |
> +			     TCPF_CLOSING | TCPF_CLOSE_WAIT))
> +				tcp_write_xmit(sk,
> +					       tcp_current_mss(sk),
> +					       0, 0,
> +					       GFP_ATOMIC);

Did you have any problems with the GFP_ATOMIC allocation failing here?
I think you move some skb allocs from process context to ATOMIC, right?

It relies on the VM somehow catching up in another context.

May be interesting to try out under very high memory pressure.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
