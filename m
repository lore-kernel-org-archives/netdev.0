From: Florian Zumbiehl <florz@gmx.de>
Subject: Re: Session ID 0 with PPPoE
Date: Wed, 7 Mar 2007 17:20:02 +0100
Message-ID: <20070307162002.GK28150@florz.florz.dyndns.org>
References: <20070304145617.GI28150@florz.florz.dyndns.org> <1173055606.12398.64.camel@kdsk1.austin.ibm.com> <20070307143205.GJ28150@florz.florz.dyndns.org> <1173281077.13894.48.camel@kdsk1.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michal Ostrowski <mostrows@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-d9bbdc34.pool.mediaWays.net ([217.187.220.52]:4021 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667AbXCGQUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 11:20:09 -0500
Content-Disposition: inline
In-Reply-To: <1173281077.13894.48.camel@kdsk1.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> This change can be made; the unbinding behavior can be removed and SID 0
> can be made valid. I hope I was clear in my previous e-mail that I
> didn't object to this.

Not quite. But now I think I got it ;-)

> PPPoE connections are unstable.  Ethernet frames get dropped.  Things
> die randomly. And yes, you typically want to have a cron job or script
> re-spawning pppd on failure.  Making this change won't increase the
> reliability of these connections in any meaningful way, it won't break
> pppd either.  

I mean, you are right from my experience that you want to have that for
pppd (which is why I _do_ have that cron job) - but your rationale
doesn't look very convincing to me. IP networks are unstable, you know.
IP packets get dropped. Things (read: TCP peers) die randomly. But no,
I don't have a cron job that restarts the MTA or web server in case some
TCP peer died - because they don't exit when some TCP connection times
out or something.

The very same thing I'd expect from pppd. If I do specify the persist
and maxfail 0 options, I expect pppd not to exit even when it receives
complete garbage from the network, much less when it receives completely
valid packets as per the RFC. The only reasonable reasons for exiting IMO
are lack of system resources or missing system features/invalid
configuration. The only reason why I do have a cron job that takes care
of restarts are all the bugs I encountered in pppd so far that caused
it to exit because it used the kernel PPP API wrongly in case of reconnects
or because it leaked ptys until there were none available anymore, not
the fact that PPP(oE) is a potentially unreliable network protocol or
because modems do lose their connection at times.

> The only question I have is why is this important to you?  I'm simply
> curious as to what you are trying to accomplish; is this related to some
> other work you are doing or is it correctness as a virtue?

It isn't extremely important to me as it doesn't affect me. But if for
any reason, then because I hope that others will take care of bugs that
they stumble across before they become a potentially difficult to solve
problem for me, too.

Florian
