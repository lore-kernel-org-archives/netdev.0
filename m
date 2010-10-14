From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] net: allocate skbs on local node
Date: Thu, 14 Oct 2010 08:31:01 -0700
Message-ID: <AANLkTin8FczYpPvi79w7iuKOZz3uZtYFfTPitAgQFxzD@mail.gmail.com>
References: <1286838210.30423.128.camel@edumazet-laptop>
	<1286839363.30423.130.camel@edumazet-laptop>
	<1286859925.30423.184.camel@edumazet-laptop>
	<20101011230322.f0f6dd47.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	Christoph Lameter <cl@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:17893 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754949Ab0JNPbG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 11:31:06 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o9EFV34I000810
	for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 08:31:03 -0700
Received: from pzk28 (pzk28.prod.google.com [10.243.19.156])
	by wpaz29.hot.corp.google.com with ESMTP id o9EFV1ea030646
	for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 08:31:02 -0700
Received: by pzk28 with SMTP id 28so1187890pzk.20
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 08:31:01 -0700 (PDT)
In-Reply-To: <20101011230322.f0f6dd47.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is all conspicuously hand-wavy and unquantified. =A0(IOW: prove =
it!)
>
> The mooted effects should be tested for on both slab and slub, I
> suggest. =A0They're pretty different beasts.
> --

Some results running netper TCP_RR test with 200 instances, 1 byte
request and response on 16 core AMD using bnx2x with one 16 queues,
one for each CPU.

SLAB

Without patch 553570 tps at 86% CPU
With patch 791883 tps at 93% CPU

SLUB

Without patch 704879 tps at 95% CPU
With patch 775278 tps at 92% CPU

I believe both show good benfits with patch, and it actually looks
like the impact is more pronounced for SLAB.  I would also note, that
we have actually already internally patched __netdev_alloc_skb to do
local node allocation which we have been running in production for
quite some time.

Tom
