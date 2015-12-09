From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Checksum offload queries
Date: Wed, 9 Dec 2015 02:56:02 +0100
Message-ID: <20151209015602.GB19097@pox.localdomain>
References: <5665A848.9010001@solarflare.com>
 <20151207.143848.2158761076110518741.davem@davemloft.net>
 <5666EC4B.40800@solarflare.com>
 <CALx6S36aMvroE0mWz9+9EU+newrfkUqqFO+6T5YZVh_9xrMJLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34428 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbbLIB4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 20:56:05 -0500
Received: by wmvv187 with SMTP id v187so239365127wmv.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 17:56:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALx6S36aMvroE0mWz9+9EU+newrfkUqqFO+6T5YZVh_9xrMJLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/15 at 09:04am, Tom Herbert wrote:
> There are other reasons why CHECKSUM_COMPLETE is preferable:
> 
> - CHECKSUM_COMPLETE  is more robust. We have no way to validate that
> the device is actually correct in CHECKSUM_UNNECESSARY. For instance,
> how do we know that there isn't some failure in the device where
> everything is being marked as good even if it's not. With
> CHECKSUM_COMPLETE it is the host that actually makes the decision of
> whether the checksum is correct it is highly unlikely that failing
> checksum calculation on the device won't be detected. HW failures and
> bugs are real concern.
> -  CHECKSUM_UNNECESSARY does not report bad checksums. There is a
> csum_bad flag in the sk_buff that could be set if the driver detects a
> bad checksum in the packet, but no drivers seem to be setting that
> currently. So for any packets with bad checksums the stack will need
> to compute the checksum itself, so this potentially becomes the basis
> of a DDOS attack. CHECKSUM_COMPLETE does not have this problem, we get
> the checksum of the packet rather the checksum is correct or not.

If I understood Edward correctly, his proposal would be for the
card to provide both, the csum as for CHECKSUM_COMPLETE plus the
validation yes/no hint. It would be up to the kernel to decide
whether to validate itself or trust the card.

I'm all in favour CHECKSUM_COMPLETE as the only way to go but 
we should be aware that it depends on the penetration of RCO in
hardware VTEPs.
