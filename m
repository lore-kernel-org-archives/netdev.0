From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Mon, 16 Nov 2009 03:15:57 -0800 (PST)
Message-ID: <20091116.031557.61986462.davem@davemloft.net>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
	<4AFA73DA.30308@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49045
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751043AbZKPLPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 06:15:41 -0500
In-Reply-To: <4AFA73DA.30308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Nov 2009 09:20:42 +0100

> I think I'll try to extend your patches with TX completion recycling too.
>
> Ie record in skb the cpu number of original sender, and queue skb to
> remote queue for destruction (sock_wfree() call and expensive
> scheduler calls...)
>
> (This probably needs driver cooperation, instead of calling consume_skb(),
> use a different function)

You can add a new argument to consume_skb() which indicates to remote
schedule a local free.

I would also suggest to record the TX cpu at dev_hard_start_xmit()
time, rather than somewhere higher up such as the socket layer.
Otherwise you'll mess up routing/netfilter cases, and also mishandle
task migration.

But a very excellent idea.

