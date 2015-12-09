From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Checksum offload queries
Date: Thu, 10 Dec 2015 00:13:03 +0100
Message-ID: <20151209231303.GJ11201@pox.localdomain>
References: <5665A848.9010001@solarflare.com>
 <20151207.143848.2158761076110518741.davem@davemloft.net>
 <5666EC4B.40800@solarflare.com>
 <CALx6S36aMvroE0mWz9+9EU+newrfkUqqFO+6T5YZVh_9xrMJLg@mail.gmail.com>
 <20151209015602.GB19097@pox.localdomain>
 <CALx6S37Dw_reYPXd9_4wCTO+BMqwQrvfMfEWDD7XCToODmm=rg@mail.gmail.com>
 <20151209222924.GG11201@pox.localdomain>
 <CALx6S34ns4e_zNzGT6wa9Un7v+P1BiY62UaDCTmS2NeQ_BpBQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34182 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753465AbbLIXNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 18:13:06 -0500
Received: by mail-wm0-f44.google.com with SMTP id v187so7816598wmv.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 15:13:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALx6S34ns4e_zNzGT6wa9Un7v+P1BiY62UaDCTmS2NeQ_BpBQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/15 at 02:51pm, Tom Herbert wrote:
> I'm sorry, I still don't understand your point. What is "automatic
> nested  checksum filling" and how does this relate to RX (e.g.
> CHECSUM_COMPLETE).

Too much compression ;-)

My understanding of the thread was that the desired state is no
checksum validation on RX and no automatic checksum offload on TX
unless explicitly instructed via csum offset. This is what I would
call a CHECKSUM_COMPLETE card (no protocol parsing).

As opposed to a CHECKSUM_UNNECESSARY card which does protocol parsing.
Some do nested checksum offload on TX as we know even if only
instructed to do one of the checksums.

So let's assume everybody goes CHECKSUM_COMPLETE and we have at most
a single level of checksum offload on TX. (As I understand, a
requirement to not break RCO anyway.) RCO would resolve the possible
software checksum performance bottleneck in the scenario of outer and
inner header checksum requirements. While I agree that this is the
case, we need to have support in hardware VTEPs for this in order for
it to be usable. (excluding those which require a checksum 0 anyway)

Multiple nested tunnels would be another beast outside of the scope of
RCO but as I stated in the other email, I don't think we should
proactively solve that.
