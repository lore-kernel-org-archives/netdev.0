From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 02/14] tcp: fix mark propagation with fwmark_reflect
 enabled
Date: Thu, 26 Jan 2017 11:28:46 -0800
Message-ID: <1485458926.5145.156.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
         <1485448687-6072-3-git-send-email-pablo@netfilter.org>
         <1485453760.5145.144.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170126191935.GA26591@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170126191935.GA26591@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-01-26 at 20:19 +0100, Pablo Neira Ayuso wrote:

> Right. This is not percpu as in IPv4.
> 
> I can send a follow up patch to get this in sync with the way we do it
> in IPv4, ie. add percpu socket.
> 
> Fine with this approach? Thanks!

Not really.

percpu sockets are going to slow down network namespace creation /
deletion and increase memory foot print.

IPv6 is cleaner because it does not really have to use different
sockets.

Ultimately would would like to have the same for IPv4.

I would rather carry the mark either in an additional parameter,
or in the flow that is already passed as a parameter.



