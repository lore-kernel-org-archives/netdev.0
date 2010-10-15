From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Couple tc filter questions.
Date: Fri, 15 Oct 2010 11:44:16 +0000
Message-ID: <20101015114416.GA9303@ff.dom.local>
References: <4CB792E0.5030704@navigue.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Thibault <jonathan@navigue.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63977 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab0JOLoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 07:44:25 -0400
Received: by bwz15 with SMTP id 15so854263bwz.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 04:44:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4CB792E0.5030704@navigue.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-10-15 01:31, Jonathan Thibault wrote:
> Since the lartc mailing list appears to be dead, I'll ask here and hope not to offend anyone.
> 
> 1- This page:
>   http://lartc.org/howto/lartc.qdisc.filters.html
> States: "Also, with HTB, you should attach all filters to the root!"
> 
> Why?  Is it still true?  My setup would be a lot easier with cascading filters.  If it's just a matter of there not being any efficiency gains from cascading filters, that's fine.  If there is a risk of things exploding randomly and without notice, I'd be keen to know.  Testing shows that cascading works okay, but I haven't tried under any serious load.

It's not true.

> 
> 2- Are filter flowid (classify) actions terminating?  Meaning if two consecutive filters would match the same packet, only the first match would ever apply and no further filter is evaluated?  Are there actions for which this isn't the case?  Intuitively and experimentally, I'd answer no but if anyone knowledgeable in the matter would care to expand on that topic I'd be grateful.  Especially considering cascading classes/filters.
> 
> Another area where termination isn't entirely clear is when using mirred and ifb devices.  I might want to send a copy of all my traffic to an ifb device, but then I would still want subsequent filters to match in the current qdisc.  In such a case, a filter that matches all traffic with a mirred action should probably not be terminating.
> 
> Maybe I'm thinking too much in terms of iptables here :P

Could you try doc/actions from iproute2 sources? Generally, anything
reasonable, not forbidden and working in tests is allowed. If still
problems please CC Jamal, the maintainer of tc classifiers (according
to linux MAINTAINERS).

Jarek P.
