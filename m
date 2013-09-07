From: Eldad Zack <eldad@fogrefinery.com>
Subject: Re: [patch net/stable] ipv6/exthdrs: accept tlv which includes only
 padding
Date: Sat, 7 Sep 2013 18:46:12 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1309071819310.24145@heraclitus>
References: <1378476145-6282-1-git-send-email-jiri@resnulli.us> <alpine.LNX.2.00.1309071427120.1262@heraclitus> <20130907154602.GA1442@minipsycho.orion>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:62688 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993Ab3IGQqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 12:46:24 -0400
Received: by mail-bk0-f47.google.com with SMTP id mx12so1707787bkb.34
        for <netdev@vger.kernel.org>; Sat, 07 Sep 2013 09:46:22 -0700 (PDT)
In-Reply-To: <20130907154602.GA1442@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 7 Sep 2013, Jiri Pirko wrote:

> Sat, Sep 07, 2013 at 02:31:36PM CEST, eldad@fogrefinery.com wrote:
> >
> >Hi Jiri,
> >
> >On Fri, 6 Sep 2013, Jiri Pirko wrote:
> >
> >> In rfc4942 and rfc2460 I cannot find anything which would implicate to
> >> drop packets which have only padding in tlv.
> >
> >NAK from my side.
> >Please read RFC4942 2.1.9.5 "Misuse of Pad1 and PadN Options".
> 
> I did.
> 
> >
> >While it doesn't specifically discusses this corner case, you can 
> >understand from "There is no legitimate reason for padding beyond the 
> >next eight octet..." that there's also no legitimate reason for an 
> >option header containing only padding.
> 
> Okay. I'm glad you agree with me and that we both understand the rfc the
> same way. And since the rfc does not say that "here's no legitimate
> reason for an option header containing only padding", this should be
> possible. I say we respect rfc and do not add stronger restrictions than
> it dictates. No need for them.

Strictly speaking, this RFC is informational, so it is doesn't dictate 
per se. I hope you don't suggest removing the other checks as well...

> >I can't imagine a sane use-case for this.
> 
> rfcs are not about sanity...

Great, we're in agreement again :) But I think the networking code is 
or should be.
What IPv6 stack would generate such a packet, given that the only usage 
of the padding options is to align other options?
Why should I accept a packet which is most likely an artificially 
crafted packet (RFC 3514)?

Cheers,
Eldad
