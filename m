From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 01/10] ftgmac100: Upgrade to NETIF_F_HW_CSUM
Date: Wed, 12 Apr 2017 09:36:05 +1000
Message-ID: <1491953765.7236.28.camel@kernel.crashing.org>
References: <20170411010436.23290-2-benh@kernel.crashing.org>
         <7d0f6000-3be5-ed70-49d3-3a3916dd79ff@cogentembedded.com>
         <1491909225.4166.248.camel@kernel.crashing.org>
         <20170411.112733.1412982560568816717.davem@davemloft.net>
         <1491948401.7236.20.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40828 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752010AbdDKXgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 19:36:16 -0400
In-Reply-To: <1491948401.7236.20.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-12 at 08:06 +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2017-04-11 at 11:27 -0400, David Miller wrote:
> > > I'll fix it in a next spin if Dave wants it that way but
> > > otherwise
> > > I'm keen to leave it as it is.
> > 
> > Please fix this and respin.
> > 
> > Meanwhile get the coding style rules changed if you disagree with
> > them.  A patch series review is not the place to argue about your
> > disagreement with the coding style rules.
> 
> I will fix.

Funny thing is, I think the code is wrong :)

I should call the helper when I don't recognize the protocol type
in the IP header, not just when the main skb protocol type is not IP.

BTW. I'm not too familiar with how encapsulation works these days. I
wouldn't throw at that HW anything other than unencapsulated packets
for HW checksumming. Is checking skb->protocol to be IP and
ip_hdr(skb)->protocol to be IP, UDP or TCP enough ? IE. Will the latter
especially return the outer header ?

Cheers,
Ben.
