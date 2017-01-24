From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] net: reset ct before calling ndo_start_xmit
Date: Tue, 24 Jan 2017 16:04:09 +0100
Message-ID: <1485270249.2409.10.camel@redhat.com>
References: <e33476125bdaf4619c221aa82c034831bbdce89b.1485250657.git.pabeni@redhat.com>
         <1485266667.16328.290.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51534 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750930AbdAXPEL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 10:04:11 -0500
In-Reply-To: <1485266667.16328.290.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-24 at 06:04 -0800, Eric Dumazet wrote:
> On Tue, 2017-01-24 at 10:40 +0100, Paolo Abeni wrote:
> 
> > Currently we use the NETIF_F_LLTX feature bit to identify such
> > devices,
> > since all the [legacy] phys drivers setting such bit are not prone
> > the hangup issue. The plan is adding a specific 'this is a
> > virtual device' priv flag and use it instead, in a later net-next
> > patch.
> 
> This is too ugly in my opinion.
> 
> LLTX is LLTX, and has absolutely nothing to do with connection
> tracking.
> 
> We have ndo_features_check, and this can be trivially backported to
> stable versions.
> 
> No need for yet another flag really.

Thank you for the feedback.

Double checking to see if I understood the above correctly: do you
suggest to call nf_reset() from the affected drivers's
ndo_features_check(), eventually adding such ndo if needed ?

I think calling nf_reset() in the common code should be better: the
conntrack entry is hot in the cache and we may want to clear it early
for as many devices as possible.

Thank you,

Paolo
