From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCHv2 iproute2 net-next] tc: m_mirred: Fix parsing of
 'index' optional argument
Date: Thu, 27 Oct 2016 22:00:40 +0300
Message-ID: <20161027220040.4e109d99@halley>
References: <20161027073606.6112-1-shmulik.ladkani@gmail.com>
        <20161027094633.GR5640@orbyte.nwl.cc>
        <20161027172239.7bf5cc40@pixies>
        <20161027145643.GS5640@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38676 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030343AbcJ0TAu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 15:00:50 -0400
Received: by mail-wm0-f41.google.com with SMTP id n67so67403524wme.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 12:00:50 -0700 (PDT)
In-Reply-To: <20161027145643.GS5640@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 27 Oct 2016 16:56:43 +0200 Phil Sutter <phil@nwl.cc> wrote:
> > Actual code, since first committed, attempts to parse "index" as 1st
> > argument (without success), see parse_mirred():
> > 
> > 	if (matches(*argv, "egress") == 0 || matches(*argv, "index") == 0) {
> > 		int ret = parse_egress(a, &argc, &argv, tca_id, n);  
> 
> Oh, I missed that! But to me this looks like the author wanted to avoid
> erroring out with "mirred option not supported index" in case of missing
> 'egress' keyword.

Could be; Not that it matters much, but evidence in parse_egress() shows
that it DOES try to parse and store "index" EVEN if no "egress" seen YET.

> Yeah, I'd go with least effort approach, i.e. not adding any additional
> flexibility in arg parsing. Since the docs never stated otherwise, I
> don't think it was a real issue for users.

Sure. It never really worked ;)

If we go that way, then some code in parse_direction needs to be
eliminated/restructured; So we'll end up with:
 - less code in parse_direction
 - not adding any additional flexibility in arg parsing
 - bigger diff than suggested

Stephen, Jamal, do you have any preference here?
