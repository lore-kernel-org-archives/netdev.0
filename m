From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH v2 00/13] ftgmac100: Rework batch 1 - Link & Interrupts
Date: Fri, 07 Apr 2017 07:46:58 +1000
Message-ID: <1491515218.4166.124.camel@kernel.crashing.org>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
         <2344b1ea-f8bc-7491-4662-b8a3e94fb94e@gmail.com>
         <1491371595.4166.77.camel@kernel.crashing.org>
         <b59025eb-e653-8481-2e58-a780777df4ee@gmail.com>
         <1491373880.4166.79.camel@kernel.crashing.org>
         <af8b8554-2788-cb48-9a13-d4d7f7085c3f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37154 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754065AbdDFVrM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 17:47:12 -0400
In-Reply-To: <af8b8554-2788-cb48-9a13-d4d7f7085c3f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-06 at 12:46 -0700, Florian Fainelli wrote:
> > I thought a while ago we could add some dev flag to prevent the link
> > watch from doing that, but never got to look into it myself and
> > apparently neither did Gavin.
> 
> It sounds like a similar situation to e.g: 802.1x, you want to let some
> frames make it through and you need a working link for that, but you
> can't quite flag the device as UP entirely. Maybe you can find a way to
> re-use IFF_LOWER_UP to that purpose and only set that flag based on the
> NC-SI frames indicating link state?

Possibly yes, I wasn't familiar with the difference between 
"carrier" and IFF_LOWER_UP so far. I'll have a look or have Gavin do
so.

It would be nice to reflect that properly so things like fallover or
bonding do the right thing. On the other hand I yet have to see a
system where the BMC has more than one NC-SI link to a NIC (what they
usually have is that NC-SI is connected to multiple NICs which is a
different matter and should be handled within the NC-SI stack).

Anyway, I'll look into it further down the track along with other
improvements I'd like to do to the NC-SI stack such as properly setting
up multicast and vlan filters in the peer NIC and various cleanups.

Cheers,
Ben.
