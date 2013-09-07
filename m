From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net/stable] ipv6/exthdrs: accept tlv which includes only padding
Date: Sun, 8 Sep 2013 00:03:28 +0200
Message-ID: <20130907220328.GB16589@order.stressinduktion.org>
References: <1378476145-6282-1-git-send-email-jiri@resnulli.us> <alpine.LNX.2.00.1309071427120.1262@heraclitus> <20130907154602.GA1442@minipsycho.orion> <alpine.LNX.2.00.1309071819310.24145@heraclitus> <20130907213445.GB1442@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eldad Zack <eldad@fogrefinery.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43759 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab3IGWDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 18:03:30 -0400
Content-Disposition: inline
In-Reply-To: <20130907213445.GB1442@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Sat, Sep 07, 2013 at 11:34:45PM +0200, Jiri Pirko wrote:
> Sat, Sep 07, 2013 at 06:46:12PM CEST, eldad@fogrefinery.com wrote:
> >
> >
> >On Sat, 7 Sep 2013, Jiri Pirko wrote:
> >
> >> Sat, Sep 07, 2013 at 02:31:36PM CEST, eldad@fogrefinery.com wrote:
> >> >
> >> >Hi Jiri,
> >> >
> >> >On Fri, 6 Sep 2013, Jiri Pirko wrote:
> >> >
> >> >> In rfc4942 and rfc2460 I cannot find anything which would implicate to
> >> >> drop packets which have only padding in tlv.
> >> >
> >> >NAK from my side.
> >> >Please read RFC4942 2.1.9.5 "Misuse of Pad1 and PadN Options".
> >> 
> >> I did.
> >> 
> >> >
> >> >While it doesn't specifically discusses this corner case, you can 
> >> >understand from "There is no legitimate reason for padding beyond the 
> >> >next eight octet..." that there's also no legitimate reason for an 
> >> >option header containing only padding.

There could be a legitimate reason: if a firewall wants to discard a HBH
or DOH it could easily zero out the option space instead of rearranging
the segment. But to make this happen in the general case all limits
regarding padding options would have to be dropped, too. That said,
I don't see this as an valid argument.

> >> 
> >> Okay. I'm glad you agree with me and that we both understand the rfc the
> >> same way. And since the rfc does not say that "here's no legitimate
> >> reason for an option header containing only padding", this should be
> >> possible. I say we respect rfc and do not add stronger restrictions than
> >> it dictates. No need for them.
> >
> >Strictly speaking, this RFC is informational, so it is doesn't dictate 
> >per se. I hope you don't suggest removing the other checks as well...
> 
> If there are some that just plainly assumes something and does
> restrictions without any solid argument, yes remove them.
> 
> >
> >> >I can't imagine a sane use-case for this.
> >> 
> >> rfcs are not about sanity...
> >
> >Great, we're in agreement again :) But I think the networking code is 
> >or should be.
> >What IPv6 stack would generate such a packet, given that the only usage 
> >of the padding options is to align other options?
> 
> But why not? I do not see anything evil about that. And rfc allows it.

It is easier to generate valid ipv6 frames which are fragmented in the
header chain. This makes it harder for firewalls to match packets etc.

This was a known attack vector with e.g. router advertisments and
fragmentation. Filters implemented in switches could be circumvented
because they did not match the fragmented RA but the host correctly did
reassemble the packet.

> >Why should I accept a packet which is most likely an artificially 
> >crafted packet (RFC 3514)?

Of course, dropping this check won't do big harm. But I actually like
the strictness of the ipv6 header chain checks and dropping this just
for the IPv6 Ready Logo doesn't seem right. Perhaps one could talk to
the people of tahi.org first?

Greetings,

  Hannes
