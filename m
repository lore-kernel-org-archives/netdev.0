From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp: avoid one cache line miss in recvmsg()
Date: Mon, 21 Nov 2016 14:01:20 -0800
Message-ID: <1479765680.8455.422.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479518283.8455.312.camel@edumazet-glaptop3.roam.corp.google.com>
         <1479764208.5596.0.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35651 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753586AbcKUWBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 17:01:21 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so29627743pga.2
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 14:01:21 -0800 (PST)
In-Reply-To: <1479764208.5596.0.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-21 at 22:36 +0100, Paolo Abeni wrote:

> Nice catch, thank you Eric!
> 
> This gives up to 8% speed-up in my performance test (wire speed udp flood
> with small packets)
> 
> Tested-by: Paolo Abeni <pabeni@redhat.com>

Thanks Paolo

Note that udp6_recvmsg() hits the 3rd cache line of skb to access
skb->protocol :

is_udp4 = (skb->protocol == htons(ETH_P_IP));

We might some trick to avoid this cache line miss.
