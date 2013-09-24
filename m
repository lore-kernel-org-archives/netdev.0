From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 10:03:25 -0700
Message-ID: <CA+mtBx_tWS44q8jER+QtR5k4k2ieq99He6YdPF8KKBF4Z2+32w@mail.gmail.com>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	<1379980991.3165.37.camel@edumazet-glaptop>
	<20130924023038.GA22393@order.stressinduktion.org>
	<20130924033505.GB22393@order.stressinduktion.org>
	<1380001118.3165.41.camel@edumazet-glaptop>
	<20130924160145.GB26769@order.stressinduktion.org>
	<1380039299.3165.91.camel@edumazet-glaptop>
	<CA+mtBx9u3-mnULxTwyWAZA4gZ6Dg-PeYYVGZibwQi7toinHJ-A@mail.gmail.com>
	<1380041185.3165.97.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:65355 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191Ab3IXRD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 13:03:26 -0400
Received: by mail-ie0-f171.google.com with SMTP id at1so9180989iec.2
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 10:03:25 -0700 (PDT)
In-Reply-To: <1380041185.3165.97.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 9:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-09-24 at 09:35 -0700, Tom Herbert wrote:
>
>> We should really be using rxhash for that anyway, eliminate this
>> ehashfn.  This would entail adding rxhash argument in the various
>> udp_lookup functions.
>
> Nope : Some NICs provide UDP rxhash only using L3  (source IP,
> destination IP), not L4 (adding source & destination ports)
>
Then the NIC won't set l4_rxhash and we'll rehash over 4-tuple when
skb_get_rxhash is called.

> This is again a case where we want our own hashing.
>
>
>
