From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 23:39:20 +0200
Message-ID: <1340833160.26242.176.camel@edumazet-glaptop>
References: <201206260734.33472.hans.schillstrom@ericsson.com>
	 <1340730156.10893.359.camel@edumazet-glaptop>
	 <1340778733.2028.110.camel@localhost>
	 <20120626.235423.588696200884989114.davem@davemloft.net>
	 <20120627195032.GI1269@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, brouer@redhat.com,
	hans.schillstrom@ericsson.com, subramanian.vijay@gmail.com,
	dave.taht@gmail.com, netdev@vger.kernel.org, ncardwell@google.com,
	therbert@google.com, mph@hoth.dk
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33467 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581Ab2F0VjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 17:39:25 -0400
Received: by bkcji2 with SMTP id ji2so1479242bkc.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 14:39:24 -0700 (PDT)
In-Reply-To: <20120627195032.GI1269@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 21:50 +0200, Florian Westphal wrote:

> I doubt using jhash is safe for syncookies.
> 
> There a several differences to other uses in kernel:
> - all hash input except u32 cookie_secret[2] is known
> - we transmit hash result (i.e, its visible to 3rd party)
> - we do not re-seed the secret, ever
> 
> it should be quite easy to recompute cookie_secret[] from known syncookie
> values?

We could re-seed the secrets every MSL seconds a bit like in
tcp_cookie_generator()

This would require check_tcp_syn_cookie() doing two checks (most recent
seed, and previous one if first check failed)
