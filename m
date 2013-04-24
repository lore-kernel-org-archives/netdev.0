From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: DMA allocation driver defined limit?
Date: Wed, 24 Apr 2013 19:41:48 +0100
Message-ID: <1366828908.2600.4.camel@bwh-desktop.uk.solarflarecom.com>
References: <CALZVapkJZotCxzMbGhZfvVV3G8W2z5tehEe7BaTjps620M+-Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30169 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757142Ab3DXSly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 14:41:54 -0400
In-Reply-To: <CALZVapkJZotCxzMbGhZfvVV3G8W2z5tehEe7BaTjps620M+-Mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 20:18 +0200, Javier Domingo wrote:
> Hi,
> 
> I am trying to find how big can the DMA memory be, as I haven't found
> anything in the docs that describes exactly a general size of DMA
> allocation, I have supposed that it depends entirely on the card.

Right.

> As a general approach, is it alright to suppose that the DMA memory
> will be as big as the internal memory of the network card?

I don't see what the network card's memory has got to do with it.  I
would expect that you can allocate and DMA-map much more memory (number
of rings * number of descriptors per ring * maximum length of
descriptor).

> The real question here is, when using DMA, the driver has a limit of
> packet size or a limit of sk_buffs it can receive? For me is like
> there should be a size limit (althought I suppose there can't be
> unlimited skbuffs).
> 
> Thanks for your attention and looking back for a replay,

Before you deliver an skb up the stack, you must DMA-unmap the header
area.  The stack then takes care of limiting the amount of memory in
use.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
