From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCHv2 iproute2 net-next] tc: m_mirred: Fix parsing of 'index'
 optional argument
Date: Thu, 27 Oct 2016 16:56:43 +0200
Message-ID: <20161027145643.GS5640@orbyte.nwl.cc>
References: <20161027073606.6112-1-shmulik.ladkani@gmail.com>
 <20161027094633.GR5640@orbyte.nwl.cc>
 <20161027172239.7bf5cc40@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53237 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936544AbcJ0O4p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 10:56:45 -0400
Content-Disposition: inline
In-Reply-To: <20161027172239.7bf5cc40@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 05:22:39PM +0300, Shmulik Ladkani wrote:
> Hi Phil,
> 
> On Thu, 27 Oct 2016 11:46:33 +0200, phil@nwl.cc wrote:
> > According to the action's help text (and the man page which is based
> > upon that), this behaviour is perfectly fine:
> > 
> > | Usage: mirred <DIRECTION> <ACTION> [index INDEX] <dev DEVICENAME>
> > 
> > So first argument *must* be the direction, second one *must* be the
> > action, then an optional index and the last one *must* be the interface.
> 
> There is an inconsistency betweem man/help and code.
> 
> Actual code, since first committed, attempts to parse "index" as 1st
> argument (without success), see parse_mirred():
> 
> 	if (matches(*argv, "egress") == 0 || matches(*argv, "index") == 0) {
> 		int ret = parse_egress(a, &argc, &argv, tca_id, n);

Oh, I missed that! But to me this looks like the author wanted to avoid
erroring out with "mirred option not supported index" in case of missing
'egress' keyword.

>From that perspective, I think parse_direction() really should be
removed and it's content made part of parse_mirred() itself.

> > While I don't see a problem with changing that (apart from that I don't
> > think it's necessary)
> 
> Not "changing" per-se, but rather "fixing", at least according code
> author's intention :)

I still think we don't fully know the author's intention. :)

> As I suggested in the notes part of the commit log,
> 
> >> An alternative solution: banning "index" as 1st argument in parse_mirred
> 
> I ok with removing the code trying to support "index" as 1st argument as
> well.
> I only assumed one might want this behaviour due to intention expressed
> by original code.

Yeah, I'd go with least effort approach, i.e. not adding any additional
flexibility in arg parsing. Since the docs never stated otherwise, I
don't think it was a real issue for users.

Cheers, Phil
