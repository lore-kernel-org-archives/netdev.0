From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: NAPI and TX
Date: Fri, 08 May 2009 15:24:38 +0100
Message-ID: <1241792678.3194.5.camel@achroite>
References: <m31vqzwzae.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:37863 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754029AbZEHOYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 10:24:44 -0400
In-Reply-To: <m31vqzwzae.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-05-08 at 14:32 +0200, Krzysztof Halasa wrote:
> Hi,
> 
> Could NAPI or something similar be used for TX in addition to RX?
> Perhaps some driver already does that?

Yes, several drivers do this.  Mostly they receive a single interrupt
for both RX and TX completions and use a single NAPI context.  PCI NICs
using MSI-X can generate distinct IRQs.

> I'm specifically thinking of IXP4xx Ethernet (and possibly WAN), those
> are 266-667 MHz ARM XScale CPUs and the interrupts handling just
> transmitted sk_buffs are a pain. Could I delay those interrupts
> somehow?

Since there are separate IRQs for RX and TX completions then you need to
set up a second NAPI context (struct napi_struct) for TX completion
handling.  Note that TX completions do not count against the "budget" so
your TX poll function should never need to return early.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

