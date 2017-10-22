From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next] tcp: do tcp_mstamp_refresh before retransmits on TSQ
 handler
Date: Sun, 22 Oct 2017 10:11:10 -0700
Message-ID: <1508692270.30291.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171022033808.12641-1-den@klaipeden.com>
         <1508644334.30291.38.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508645419.9317.7.camel@klaipeden.com>
         <1508649690.30291.44.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508677159.3011.1.camel@klaipeden.com>
         <1508690944.30291.48.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ncardwell@google.com
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:49694 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751406AbdJVRLN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 13:11:13 -0400
Received: by mail-pg0-f52.google.com with SMTP id g6so10058788pgn.6
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 10:11:13 -0700 (PDT)
In-Reply-To: <1508690944.30291.48.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-10-22 at 09:49 -0700, Eric Dumazet wrote:

> Here is the test I cooked.
> 
> Note that it actually passes just fine, do I am wondering if your patch
> is needed after all..
> 

Oh this is because tcp_mstamp_refresh() is called from tcp_write_xmit()
and tcp_write_xmit() is directly called from tcp_tsq_handler()

So it looks your patch has no observable effect.

(Even with usec TS as we use here at Google, it has no effect since TCP
stack does not consider RTT samples being valid if skb was ever
retransmitted)
