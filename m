From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [RFC] net: napi fix
Date: Wed, 12 Dec 2007 15:05:26 +0900
Message-ID: <b25c3fa70712112205l2e778bacx66470606272b199@mail.gmail.com>
References: <002901c83c73$b089b6e0$9c94fea9@jason>
	 <20071211213939.122de1db@freepuppy.rosehill>
	 <20071211214634.4dedb274@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	baum@tehutinetworks.net, andy@greyhouse.net
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ro-out-1112.google.com ([72.14.202.181]:3618 "EHLO
	ro-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445AbXLLGF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 01:05:28 -0500
Received: by ro-out-1112.google.com with SMTP id p4so146865roc.5
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 22:05:27 -0800 (PST)
In-Reply-To: <20071211214634.4dedb274@freepuppy.rosehill>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2007/12/12, Stephen Hemminger <shemminger@linux-foundation.org>:
> Isn't this a better fix for all drivers, rather than peppering every
> driver with the special case. This is how the logic worked up until
> 2.6.24.
>
>
> --- a/net/core/dev.c    2007-12-11 12:16:20.000000000 -0800
> +++ b/net/core/dev.c    2007-12-11 21:43:39.000000000 -0800
> @@ -2184,7 +2184,7 @@ static void net_rx_action(struct softirq
>
>                have = netpoll_poll_lock(n);
>
> -               weight = n->weight;
> +               weight = min(n->weight, budget);
>
>                /* This NAPI_STATE_SCHED test is for avoiding a race
>                 * with netpoll's poll_napi().  Only the entity which
>

Stephen,
Could you explain how it fix the problem?
IMHO I think your patch cannot solve the problem.
The drivers can call netif_rx_complete and net_rx_action can do
list_move_tail also.
Am I missing something?

Thanks
Joonwoo
