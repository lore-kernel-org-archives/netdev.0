From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 iproute2 net-next] tc: m_mirred: Fix parsing of
 'index' optional argument
Date: Tue, 29 Nov 2016 12:34:05 -0800
Message-ID: <20161129123405.4008d526@samsung9>
References: <20161027073606.6112-1-shmulik.ladkani@gmail.com>
        <20161027094633.GR5640@orbyte.nwl.cc>
        <20161027172239.7bf5cc40@pixies>
        <20161027145643.GS5640@orbyte.nwl.cc>
        <20161027220040.4e109d99@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, Jamal Hadi Salim <jhs@mojatatu.com>,
        netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36485 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754468AbcK2UeI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 15:34:08 -0500
Received: by mail-pg0-f50.google.com with SMTP id f188so72842440pgc.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 12:34:07 -0800 (PST)
In-Reply-To: <20161027220040.4e109d99@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Oct 2016 22:00:40 +0300
Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:

> Hi,
> 
> On Thu, 27 Oct 2016 16:56:43 +0200 Phil Sutter <phil@nwl.cc> wrote:
> > > Actual code, since first committed, attempts to parse "index" as 1st
> > > argument (without success), see parse_mirred():
> > > 
> > > 	if (matches(*argv, "egress") == 0 || matches(*argv, "index") == 0) {
> > > 		int ret = parse_egress(a, &argc, &argv, tca_id, n);    
> > 
> > Oh, I missed that! But to me this looks like the author wanted to avoid
> > erroring out with "mirred option not supported index" in case of missing
> > 'egress' keyword.  
> 
> Could be; Not that it matters much, but evidence in parse_egress() shows
> that it DOES try to parse and store "index" EVEN if no "egress" seen YET.
> 
> > Yeah, I'd go with least effort approach, i.e. not adding any additional
> > flexibility in arg parsing. Since the docs never stated otherwise, I
> > don't think it was a real issue for users.  
> 
> Sure. It never really worked ;)
> 
> If we go that way, then some code in parse_direction needs to be
> eliminated/restructured; So we'll end up with:
>  - less code in parse_direction
>  - not adding any additional flexibility in arg parsing
>  - bigger diff than suggested
> 
> Stephen, Jamal, do you have any preference here?

My only demand is not to break existing users.
Jamal is the original developer of mirred so I would like his feedback.
