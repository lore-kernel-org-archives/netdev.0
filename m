From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [RFC PATCH] net: limit maximum number of packets to mark with
 xmit_more
Date: Fri, 25 Aug 2017 16:24:05 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5882A8A790@ORSMSX115.amr.corp.intel.com>
References: <20170825152449.29790-1-jacob.e.keller@intel.com>
        <E0D909EE5BB15A4699798539EA149D7F07793B3E@ORSMSX103.amr.corp.intel.com>
 <20170825085816.3425a70c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
        "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45430 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934196AbdHYQYK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 12:24:10 -0400
In-Reply-To: <20170825085816.3425a70c@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Friday, August 25, 2017 8:58 AM
> To: Waskiewicz Jr, Peter <peter.waskiewicz.jr@intel.com>
> Cc: Keller, Jacob E <jacob.e.keller@intel.com>; netdev@vger.kernel.org
> Subject: Re: [RFC PATCH] net: limit maximum number of packets to mark with
> xmit_more
> 
> xmit_more is only a hint to the device. The device driver should ignore it unless
> there are hardware advantages. The device driver is the place with HW specific
> knowledge (like 4 Tx descriptors is equivalent to one PCI transaction on this
> device).
> 
> Anything that pushes that optimization out to the user is only useful for
> benchmarks
> and embedded devices.

Right so most drivers I've seen simply take it as a "avoid bumping tail of a ring" whenever they see xmit_more. But unfortunately in some circumstances, this results in potentially several hundred packets being set with xmit_more in a row, and then the driver doesn't bump the tail for a long time, resulting in high latency spikes..

I was trying to find a way to fix this potentially in multiple drivers, rather than just a single driver, since I figured the same sort of code might need to be needed.

So you're suggesting we should just perform some check in the device driver, even if it might be duplication?

We could also instead make it a setting in the netdev struct or something which would be set by the driver and then tell stack code to limit how many it sends at once (so that we don't need to duplicate that checking code in every driver?)

Thanks,
Jake
