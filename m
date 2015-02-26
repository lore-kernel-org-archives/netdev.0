From: "tgraf@suug.ch" <tgraf@suug.ch>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Thu, 26 Feb 2015 10:02:35 +0000
Message-ID: <20150226100235.GA16032@casper.infradead.org>
References: <cover.1424877322.git.daniel@iogearbox.net>
 <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CAED36D@AcuExch.aculab.com>
 <54EDEE55.8050605@iogearbox.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CAED3A1@AcuExch.aculab.com>
 <54EDF4DD.1060709@iogearbox.net>
 <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56284 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736AbbBZKCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 05:02:40 -0500
Content-Disposition: inline
In-Reply-To: <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/15 at 09:41am, Eric Dumazet wrote:
> There is no need to track number of elements, using either an atomic_t
> or percpu_counter. This adds unnecessary burden.
> 
> 1) Automatic shrinking is a non issue. This will free very little
> memory, compared to previous peak usage (including objects put in
> rhashtable). If hash grown to a certain point, it's likely it will grow
> again later.
> 
> 2) Growing can be triggered when any bucket has more than X elems, and
> that is given for free at insert time.
> X could be log2(buckets)/2 I guess. (aka shift/2)
> 
> A global limit on number of elements should be controlled by rhashtable
> users - if needed -, not in the rhashtable itself.

I don't think we need to kill shrink to get rid of the elements
counters. It looks all users of shrink could trigger it manually
by maintaing their own element counter, we just have to export the
shrink function.

I just want to point out here that TCP is not the only future
use case. The station table for mac80211 has recently been
converted. We need to keep all of them on the radar.
