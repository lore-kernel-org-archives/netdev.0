From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCHv2 net-next 1/2] tcp: RTO Restart (RTOR)
Date: Tue, 08 Dec 2015 05:47:10 -0800
Message-ID: <1449582430.7632.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1449478261.git.per.hurtig@kau.se>
	 <cover.1449561786.git.per.hurtig@kau.se>
	 <8cd2c4817d86e30b09fe398c6bfcb7a89521bdb3.1449561786.git.per.hurtig@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, ncardwell@google.com,
	nanditad@google.com, tom@herbertland.com, ycheng@google.com,
	viro@zeniv.linux.org.uk, fw@strlen.de, mleitner@redhat.com,
	daniel@iogearbox.net, willemb@google.com,
	ilpo.jarvinen@helsinki.fi, pasi.sarolahti@iki.fi,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	anna.brunstrom@kau.se, apetlund@simula.no, michawe@ifi.uio.no,
	mohammad.rajiullah@kau.se
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34384 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756400AbbLHNrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 08:47:14 -0500
Received: by pacwq6 with SMTP id wq6so12378079pac.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 05:47:13 -0800 (PST)
In-Reply-To: <8cd2c4817d86e30b09fe398c6bfcb7a89521bdb3.1449561786.git.per.hurtig@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-08 at 10:19 +0100, Per Hurtig wrote:

> +static u32 tcp_unsent_pkts(const struct sock *sk, u32 ulimit)
> +{
> +	struct sk_buff *skb = tcp_send_head(sk);
> +	u32 pkts = 0;
> +
> +	if (skb)
> +		tcp_for_write_queue_from(skb, sk) {
> +			pkts += tcp_skb_pcount(skb);
> +
> +			if (ulimit && pkts >= ulimit)
> +				return ulimit;
> +		}
> +
> +	return pkts;
> +}


Considering Yuchung feedback, have you looked at using an approximation
instead ? 

(ie using tp->write_seq - tp->snd_nxt)
