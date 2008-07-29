From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: incoming interface + ifb0
Date: Tue, 29 Jul 2008 12:48:23 +0000
Message-ID: <20080729124823.GA26788@ff.dom.local>
References: <200807291322.10084.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:59518 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbYG2MnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 08:43:10 -0400
Received: by ug-out-1314.google.com with SMTP id h2so142996ugf.16
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 05:43:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200807291322.10084.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29-07-2008 12:22, Denys Fedoryshchenko wrote:
> Sorry that i am asking in kernel maillist, probably it is wrong. Maybe right place is lartc only, but probably kernel lacking something too :-)
> 
> Question is:
> I have plenty pppX interfaces. I want to shape traffic coming over this interfaces.
> Before i was doing over m_ipt and MARK, then redirect to ifb0 and there was doing filter by fwmark.
> But m_ipt seems needs serious rewrite, and plus it is not very clean way to do (performance wise).
> 
> Alternative way is to shape on outgoing interface, but it is not clean, in case if there is multiple outgoing interfaces. 
> I tried to filter on ifb by ematch - rt_iif, dev - no luck. by route fromif - no luck. Is there some way i miss?

I didn't use this nor checked enough, so I can be wrong, but
since ingress with ifb0 is in prerouting, you probably can't use
rt_iif. You shouldn't filter at ifb on "dev" neither - it's "ifb"
at the moment. You need to match skb->iif with something (flow?).

Jarek P.
