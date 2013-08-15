From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Fwd: RFC 6980 on Security Implications of IPv6 Fragmentation with IPv6 Neighbor Discovery
Date: Thu, 15 Aug 2013 12:04:07 +0200
Message-ID: <20130815100407.GA18564@order.stressinduktion.org>
References: <20130813221321.AEA1AB1E003@rfc-editor.org> <520B3D81.9070506@gont.com.ar> <20130814230617.GA13066@order.stressinduktion.org> <520C7519.1010000@gont.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>
To: Fernando Gont <fernando@gont.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53288 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976Ab3HOKEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 06:04:08 -0400
Content-Disposition: inline
In-Reply-To: <520C7519.1010000@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 03:28:41AM -0300, Fernando Gont wrote:
> Thanks so much for your timely response! -- Please find my comments
> in-line...
> 
> On 08/14/2013 08:06 PM, Hannes Frederic Sowa wrote:
> > On Wed, Aug 14, 2013 at 05:19:13AM -0300, Fernando Gont wrote:
> >> Folks,
> >>
> >> FYI. -- this is an important piece when it comes to First Hop (i.e.,
> >> "local link") Security.
> > 
> > Thanks for the heads-up, Fernando!
> > 
> > I sketched up a patch to protect the receiving side. I still don't know if I
> > should make this behaviour default or configurable via a sysctl knob. I really
> > don't want to break existing installations.
> 
> Make it the default behavior. If anything, provide a sysctl knob to
> override it.
> 
> Note: In the specific case of NS/NA messages, it's impossible nowadays
> to find them fragmented in a real network (we don't even have options
> (other than padding) to make NS/NAs grow so large!).

Yes, I also do favour making this the default behavior.

> > As an extra plus, we now discard packets with nested fragment headers at once.
> > Those packets should never have been accepted.
> 
> Is that the "goto fail_hdr" part in your patch?

Yes, still have to check if I should silently ignore them or generate a
parameter problem (that is the current behavior).

> 
> P.S.: What about RS/RA messages?


ndisc_rcv, which does now silently discard fragmented packets, is called
for the following types:

        case NDISC_ROUTER_SOLICITATION:
        case NDISC_ROUTER_ADVERTISEMENT:
        case NDISC_NEIGHBOUR_SOLICITATION:
        case NDISC_NEIGHBOUR_ADVERTISEMENT:
        case NDISC_REDIRECT:

So all packet types from RFC6980 should be covered (we do not support SEND,
yet).

Thanks,

  Hannes
