From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: incoming interface + ifb0
Date: Tue, 29 Jul 2008 20:31:28 +0200
Message-ID: <20080729183128.GA2556@ami.dom.local>
References: <20080729124823.GA26788@ff.dom.local> <200807291626.36572.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:41411 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbYG2Sb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 14:31:59 -0400
Received: by ug-out-1314.google.com with SMTP id h2so185527ugf.16
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 11:31:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200807291626.36572.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2008 at 04:26:36PM +0300, Denys Fedoryshchenko wrote:
> On Tuesday 29 July 2008, Jarek Poplawski wrote:
> 
> > I didn't use this nor checked enough, so I can be wrong, but
> > since ingress with ifb0 is in prerouting, you probably can't use
> > rt_iif. You shouldn't filter at ifb on "dev" neither - it's "ifb"
> > at the moment. You need to match skb->iif with something (flow?).
> Yes
> I want to create on outgoing device or ifb(preffered) - tree of flows.
> Cause each interface = customer - i need to classify customers by flows.
> 
> Since customer can have multiple/spoofed ip's - i cannot filter by ip for now.
> So iif only my choice seems.
> 
> Maybe if i do redirect on outgoing to ifb on outgoing device it will work?

I doubt you can do something like this - or I miss something. IMHO,
you could try with this flow filter on ifb as a replacement for ipt
+ fw. Otherwise, if you can schedule on outgoing devs, you can use
e.g.  cls_route. On the other hand ppp usually enables controlling
of clients, so maybe you should better try to use this more.

Jarek P.
