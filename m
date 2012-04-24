From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive for
 TCP
Date: Tue, 24 Apr 2012 11:01:37 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1204241026410.735@wel-95.cs.helsinki.fi>
References: <1335173934.3293.84.camel@edumazet-glaptop>  <4F958DFD.7010207@hp.com> <1335201795.5205.35.camel@edumazet-glaptop>  <20120423.160149.1515408777176168288.davem@davemloft.net>  <1335213446.5205.65.camel@edumazet-glaptop>
 <1335234012.5205.97.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	Netdev <netdev@vger.kernel.org>, therbert@google.com,
	ncardwell@google.com, maze@google.com,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36817 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829Ab2DXIBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 04:01:39 -0400
In-Reply-To: <1335234012.5205.97.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Apr 2012, Eric Dumazet wrote:

> On Mon, 2012-04-23 at 22:37 +0200, Eric Dumazet wrote:
> 
> > We could try to coalesce ACKs before backlogging them. I'll work on
> > this.
> 
> I did an experiment, and found a basic coalescing was not working in
> case of packet loss and SACK storm.

...That case might also have some performance issues at the receiver end 
when a hole is filled and TCP pushes stuff higher up.

> Doing a smart coalescing in this case sounds really complex.

Why's that? ...We'd compare options 32-bit at a time (like you already do 
anyway) and if we find difference we check the previous bits to validate 
it's a SACK option (the changing one should be in the first start-end 
pair). ...As long as there's no hole in every other segment we'd be 
winners I think.

> Should we really continue this way ? 

Why not, but wouldn't it be nicer to coalesce them already in GRO below 
with an assumption that GRO is likely to find some "mss" equivivalent 
which tells the gap between consecutive ACK (or even SACK) seqnos?

I've been long thinking that it would be nice to run offloading for ACKs 
too, and possibly even for SACKs, in both ends, although that might not be 
possible with other than GSO/GRO, at least atm.


-- 
 i.
