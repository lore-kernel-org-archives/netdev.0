From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1] tproxy: do not assign timewait sockets to skb->sk
Date: Mon, 14 Feb 2011 16:51:58 +0100
Message-ID: <4D594F9E.2090100@trash.net>
References: <1297683874-10188-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>,
	KOVACS Krisztian <hidden@balabit.hu>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55516 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755404Ab1BNPv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 10:51:59 -0500
In-Reply-To: <1297683874-10188-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 14.02.2011 12:44, schrieb Florian Westphal:
> Assigning a socket in timewait state to skb->sk can trigger
> kernel oops, e.g. in nfnetlink_log, which does:
> 
> if (skb->sk) {
>         read_lock_bh(&skb->sk->sk_callback_lock);
>         if (skb->sk->sk_socket && skb->sk->sk_socket->file) ...
> 
> in the timewait case, accessing sk->sk_callback_lock and sk->sk_socket
> is invalid.
> 
> Either all of these spots will need to add a test for sk->sk_state != TCP_TIME_WAIT,
> or xt_TPROXY must not assign a timewait socket to skb->sk.
> 
> This does the latter.
> 
> If a TW socket is found, assign the tproxy nfmark, but skip the skb->sk assignment,
> thus mimicking behaviour of a '-m socket .. -j MARK/ACCEPT' re-routing rule.
> 
> The 'SYN to TW socket' case is left unchanged -- we try to redirect to the
> listener socket.
> 
> Cc: Balazs Scheidler <bazsi@balabit.hu>
> Cc: KOVACS Krisztian <hidden@balabit.hu>
> Signed-off-by: Florian Westphal <fwestphal@astaro.com>

Looks fine to me. Balazs. Krisztian, any objections?
