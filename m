From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 v3] xps: Improvements in TX queue selection
Date: Mon, 25 Oct 2010 11:56:13 -0700 (PDT)
Message-ID: <20101025.115613.71111117.davem@davemloft.net>
References: <alpine.DEB.1.00.1010211303390.30535@pokey.mtv.corp.google.com>
	<20101024.153206.179940220.davem@davemloft.net>
	<AANLkTi=Pzxnf=bJXANwz8Rmd8GOUu9oxpO_YF6udJE01@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35630
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753057Ab0JYSzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 14:55:50 -0400
In-Reply-To: <AANLkTi=Pzxnf=bJXANwz8Rmd8GOUu9oxpO_YF6udJE01@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 25 Oct 2010 10:02:05 -0700

> Would this be sufficient:
> 
> @@ -825,7 +825,8 @@ static int tcp_transmit_skb(struct sock *sk,
> struct sk_buff *skb
>         if (tcp_packets_in_flight(tp) == 0) {
>                 tcp_ca_event(sk, CA_EVENT_TX_START);
>                 skb->ooo_okay = 1;
> -       }
> +       } else
> +               skb->ooo_okay = 0;

Or, alternatively, you could clear it at the point it's tested in
the device transmit path.

This might make the changes for SCTP and other protocols much
easier.

For now, either way is fine with me.
