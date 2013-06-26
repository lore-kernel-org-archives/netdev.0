From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] about "net: orphan frags on receive" insanity
Date: Wed, 26 Jun 2013 03:12:23 -0700
Message-ID: <1372241543.3301.157.camel@edumazet-glaptop>
References: <1372235039.3301.126.camel@edumazet-glaptop>
	 <20130626095642.GA20982@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:60018 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762Ab3FZKMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 06:12:21 -0400
Received: by mail-ee0-f44.google.com with SMTP id c13so7239651eek.17
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 03:12:20 -0700 (PDT)
In-Reply-To: <20130626095642.GA20982@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-26 at 12:56 +0300, Michael S. Tsirkin wrote:

> Please don't just revert it.

I said "revert and fix the callers"

> 
> Packets can cross e.g. the bridge and end up on the external
> interface, in which case that NIC guarantees that
> they will get transmitted eventually, so it's safe
> to transmit from guest memory, or they can end up
> in the host stack where they can stay indefinitely,
> in this case we need to orphan frags so guest networking
> can keep going.
> 
> What do you suggest exactly?
> 
> Also, I'll have to look at the generated binary - when I
> coded this up, compiler seemed to only put a
> conditional branch on the fast path, this shouldn't
> be all that expensive.

Then look again. Its 400 bytes right now.

I suggested to call this only from the impacted callers.

VM are fine, but if we slow down bare metal to close the gap, or make
appealing kernel bypass, that's not very fair.

Why normal frames received from real NIC should pay this price, I don't
know.

The conditional branch might sound not expensive, but the cache line
miss on skb_shinfo(skb)->tx_flags is expensive.
