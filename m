From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: Reflect RX hash for transmit
Date: Mon, 16 Feb 2015 04:29:56 -0800
Message-ID: <1424089796.4942.57.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424025438-1659-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:42399 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbbBPM37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 07:29:59 -0500
Received: by mail-qc0-f178.google.com with SMTP id p6so23757793qcv.9
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 04:29:58 -0800 (PST)
In-Reply-To: <1424025438-1659-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-02-15 at 10:37 -0800, Tom Herbert wrote:
> This patch allows a driver to request that the receive hash it provides
> to the stack is reflected back in skb->hash for packets transmitted
> on the associated connection. The hash value returned by a device could
> have meaning when used in transmit to identify a flow, for instance
> the hash may by a flow ID for a flow created in a (virtual) device.
> With the flow ID provided on transmit this can obviate the need
> to create the hash and do the lookup on the fly in transmit.
> 
> Note that this is an opportunistic optimization, there is no
> separate negotiation between the stack and driver/device for
> the hash used in either TX or RX.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

It is not clear to me why we would want to consume yet another skb->bit
for this.

This seems it might be a socket attribute, rather than a device provided
one on every packet.

Anyway, this seems a premature change, as no driver currently needs this
yet ?
