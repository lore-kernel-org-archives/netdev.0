From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/4] udp: add busylocks in RX path
Date: Thu, 08 Dec 2016 11:57:29 -0800
Message-ID: <1481227049.4930.132.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481226117-31288-1-git-send-email-edumazet@google.com>
         <1481226117-31288-2-git-send-email-edumazet@google.com>
         <1481226350.1892859.812996409.6D78D4D7@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33986 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752866AbcLHT6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 14:58:31 -0500
Received: by mail-pg0-f67.google.com with SMTP id e9so27683877pgc.1
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 11:58:30 -0800 (PST)
In-Reply-To: <1481226350.1892859.812996409.6D78D4D7@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-08 at 20:45 +0100, Hannes Frederic Sowa wrote:
> Hi Eric,
> 

> This patch mostly improves situation for non-connected sockets. Do you
> think it makes sense to acquire the spinlock depending on the sockets
> state? Connected UDP sockets flow in on one CPU anyway?

We could do that, definitely.

However I could not measure any difference with a conditional test here
for connected socket.

Maybe it would show up if we are unlucky and multiple cpus compete on
the same cache line because of the hashed spinlock array.
