From: Javier Domingo <javierdo1@gmail.com>
Subject: Re: DMA allocation driver defined limit?
Date: Thu, 25 Apr 2013 23:15:16 +0200
Message-ID: <CALZVapn-95Sg33fgzkQGfR6C0t40OZNJAh_e8CoS3E7GL7eiig@mail.gmail.com>
References: <CALZVapkJZotCxzMbGhZfvVV3G8W2z5tehEe7BaTjps620M+-Mw@mail.gmail.com>
 <1366828908.2600.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f175.google.com ([209.85.128.175]:39700 "EHLO
	mail-ve0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758852Ab3DYVPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 17:15:36 -0400
Received: by mail-ve0-f175.google.com with SMTP id m1so1520223ves.34
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 14:15:36 -0700 (PDT)
In-Reply-To: <1366828908.2600.4.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't see what the network card's memory has got to do with it.  I
> would expect that you can allocate and DMA-map much more memory (number
> of rings * number of descriptors per ring * maximum length of
> descriptor).

So the limit is on number of skbuff nuber and it is self-imposed by the card.

> Before you deliver an skb up the stack, you must DMA-unmap the header
> area. The stack then takes care of limiting the amount of memory in
> use.

I have found that the limit on rings is consistent, as it only
allocates another area when the later one is unmapped.

One last question is: If netdev_budget is 300, why the DMA ring size
is 256 by default in e1000? Shouldn't it be greater than 300, so that
if it has enought packets in one softirq, it could capture them?

Thanks a lot for the reply,

Javier Domingo
