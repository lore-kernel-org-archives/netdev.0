From: Koichiro Den <den@klaipeden.com>
Subject: Re: [net-next] tcp: do tcp_mstamp_refresh before retransmits on TSQ
 handler
Date: Mon, 23 Oct 2017 13:28:45 +0900
Message-ID: <1508732925.2898.7.camel@klaipeden.com>
References: <20171022033808.12641-1-den@klaipeden.com>
         <1508644334.30291.38.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508645419.9317.7.camel@klaipeden.com>
         <1508649690.30291.44.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508677159.3011.1.camel@klaipeden.com>
         <1508690944.30291.48.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508692270.30291.53.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508729177.2898.5.camel@klaipeden.com>
         <1508730005.30291.70.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net, ncardwell@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21312 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750861AbdJWE2w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 00:28:52 -0400
In-Reply-To: <1508730005.30291.70.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-10-22 at 20:40 -0700, Eric Dumazet wrote:
> On Mon, 2017-10-23 at 12:26 +0900, Koichiro Den wrote:
> 
> > Now I wonder this is more of a theoretical one rather than a patch to fix
> > one
> > specific bug.
> 
> 
> Note that I said that your patch was fine and I added a 'Reviewed-by:'
> tag.
Sure, sorry about my confusing comment.
> 
> 
> What I meant is that it has no direct effect on correctness of TCP
> stack. I could not cook a packetdrill test that shows the difference
> before and after your patch.
> 
> BTW, in the following sequence :
> 
> A)   Fetch high-res timestamp and store in X
> B)   Use X
> 
> B) Can use a quite old value of X, depending on scheduling (preempt
> kernels or interrupt handling)
> 
> TCP really does not care of how accurate X is, it is a best effort.
> 
I agreed. In e.g., hard interrupt storm, this extra refreshing is just
make the expected delay smaller under the same condition.
> For RTX packets, it is even more the case, since TCP does not take RTT
> samples from packets that were retransmitted.
Indeed, meaning that tcp_clean_rtx_queue implementation never takes.
But for me it seems that there is some possibility RACK algorithm will take it.
