From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next] tcp: do tcp_mstamp_refresh before retransmits on TSQ
 handler
Date: Sun, 22 Oct 2017 20:40:05 -0700
Message-ID: <1508730005.30291.70.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171022033808.12641-1-den@klaipeden.com>
         <1508644334.30291.38.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508645419.9317.7.camel@klaipeden.com>
         <1508649690.30291.44.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508677159.3011.1.camel@klaipeden.com>
         <1508690944.30291.48.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508692270.30291.53.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508729177.2898.5.camel@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ncardwell@google.com
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:55346 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdJWDkI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 23:40:08 -0400
Received: by mail-pg0-f43.google.com with SMTP id 15so6047686pgc.12
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 20:40:08 -0700 (PDT)
In-Reply-To: <1508729177.2898.5.camel@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-23 at 12:26 +0900, Koichiro Den wrote:

> Now I wonder this is more of a theoretical one rather than a patch to fix one
> specific bug.


Note that I said that your patch was fine and I added a 'Reviewed-by:'
tag.


What I meant is that it has no direct effect on correctness of TCP
stack. I could not cook a packetdrill test that shows the difference
before and after your patch.

BTW, in the following sequence :

A)   Fetch high-res timestamp and store in X
B)   Use X

B) Can use a quite old value of X, depending on scheduling (preempt
kernels or interrupt handling)

TCP really does not care of how accurate X is, it is a best effort.

For RTX packets, it is even more the case, since TCP does not take RTT
samples from packets that were retransmitted.
