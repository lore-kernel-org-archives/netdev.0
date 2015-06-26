From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Why can't we SNAT (or inverse DNAT) in PREROUTING?
Date: Sat, 27 Jun 2015 00:48:25 +0200
Message-ID: <20150626224825.GB28820@electric-eye.fr.zoreil.com>
References: <CALCETrWRv5S_X=MQRGwO-NR+XrQc2o-EnooHFN0V41xqJEY8sA@mail.gmail.com>
 <20150626203249.GA28820@electric-eye.fr.zoreil.com>
 <CALCETrUR9VKJ0jJwqF79Jm6Y954yhMrA=ifzRWCvvgHzOpgzag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55110 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124AbbFZWsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 18:48:37 -0400
Content-Disposition: inline
In-Reply-To: <CALCETrUR9VKJ0jJwqF79Jm6Y954yhMrA=ifzRWCvvgHzOpgzag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Lutomirski <luto@amacapital.net> :
> [re-add netdev -- I assume you meant to reply all]

Thanks. Late friday.

> On Fri, Jun 26, 2015 at 1:32 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> > Andy Lutomirski <luto@amacapital.net> :
> > [...]
> >> Could we add some option to do SNAT and inverse DNAT before routing?
> >
> > I haven't used it for ages but what's wrong with iptables + fwmark ?
> >
> > It takes place in PREROUTING.
> 
> This works, but it seems unnecessarily painful.  It means that all of
> my policy rules have to be duplicated with fwmark rules based on '-m
> conntrack' or similar.

I'd rather say that the fwmark rules will duplicate the SNAT rules since
your routing policy depends on the post SNAT source addresses. You'd
be right to complain it does not really help :o)

> Shouldn't the order of operations be:
> 
> 1. Check rp_filter.
> 
> 2. Handle NAT.
> 
> 3. Routing decision.
> 
> ?

The admittedly painful fwmark part would still be needed for pre-NAT
source address based policy routing (assuming SNAT loses valuable policy
information). Life would be easier for your current requirements but
some different policy requirements would be unable to avoid the
fwmark/mangle style stuff.

Btw, the suggested scheme implies that filtering between SNAT and DNAT
would be done before routing, thus without INPUT vs FORWARD tainting.

It may be done but it would be a different beast and I can't help thinking
that routing and filtering would overlap.

-- 
Ueimor
