From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] tcp: fix dynamic right sizing
Date: Tue, 24 Sep 2013 11:16:56 -0400 (EDT)
Message-ID: <20130924.111656.573791642060379443.davem@redhat.com>
References: <1379710618.3431.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	vanj@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54033 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038Ab3IXPRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 11:17:08 -0400
In-Reply-To: <1379710618.3431.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Sep 2013 13:56:58 -0700

> Dynamic Right Sizing (DRS) is supposed to open TCP receive window
> automatically, but suffers from two bugs, presented by order
> of importance.
> 
> 1) tcp_rcv_space_adjust() fix :
> 
> Using twice the last received amount is very pessimistic,
> because it doesn't allow fast recovery or proper slow start
> ramp up, if sender wants to increase cwin by 100% every RTT.
> 
> copied = bytes received in previous RTT
> 
> 2*copied = bytes we expect to receive in next RTT
> 
> 4*copied = bytes we need to advertise in rwin at end of next RTT
> 
> DRS is one RTT late, it needs a 4x factor.
> 
> If sender is not using ABC, and increases cwin by 50% every rtt,
> then we needed 1.5*1.5 = 2.25 factor.
> This is probably why this bug was not really noticed.
> 
> 2) There is no window adjustment after first RTT. DRS triggers only
>   after the second RTT.
>   DRS needs two RTT to initialize, so tcp_fixup_rcvbuf() should setup
>   sk_rcvbuf to allow proper window grow for first two RTT.
> 
> This patch increases TCP efficiency particularly for large RTT flows
> when autotuning is used at the receiver, and more particularly
> in presence of packet losses.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Cc: Van Jacobson <vanj@google.com>

Looks good, applied, thanks Eric.
