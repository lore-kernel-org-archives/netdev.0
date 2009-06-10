From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ntohs() and htons() usgae in the network stack
Date: Wed, 10 Jun 2009 15:24:12 +0100
Message-ID: <1244643852.2848.6.camel@achroite>
References: <55c333c0906100708q1b0be2ffkc80c2f3258f0e681@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:40000 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754438AbZFJOYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 10:24:14 -0400
In-Reply-To: <55c333c0906100708q1b0be2ffkc80c2f3258f0e681@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-06-10 at 17:08 +0300, Kevin Wilson wrote:
> Hello,
> I will appreciate if someone can explain this mystery to me:
> 
> While debugging some kernel module, I added printing of ports.
> I had printer both ntohs() and htons() of a port number. I got the same
> values.
[...]

Yes, these functions have exactly the same effect on the bits of the
value.  But "16-bit unsigned value in host order" (u16) and "16-bit
unsigned value in network order" (__be16) should be considered as two
different types, requiring different functions for conversion each way.
The "sparse" static analyser can treat them as separate types and can
catch missing conversions.  If we used a single conversion function this
would not be possible.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

