From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2/7] [CCID-2]: Remove ccid2hc{tx,rx}_ prefixes
Date: Tue, 27 May 2008 15:07:44 +0100
Message-ID: <20080527140744.GA28240@gerrit.erg.abdn.ac.uk>
References: <1211877167-10995-1-git-send-email-gerrit@erg.abdn.ac.uk> <1211877167-10995-2-git-send-email-gerrit@erg.abdn.ac.uk> <1211877167-10995-3-git-send-email-gerrit@erg.abdn.ac.uk> <20080527.062536.64095383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:40009 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756782AbYE0OHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 10:07:53 -0400
Content-Disposition: inline
In-Reply-To: <20080527.062536.64095383.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| The whole reason we use these member prefixes is so that the
| tree is actually greppable.  tcp_sock is the way it is because
| we never enforced this useful policy back when it was originally
| created.
| 
| If you use short member names, it becomes eventually impossible
| to grep for "->foo" and have it not match a ton of crap you
| are completely not interested in.  Using a prefix creates a
| struct member namespace, and thus fixes that problem.
| 
Ok, but this creates two problems at another end:

 1/ as it is, the code is very hard to read, since 80% of expressions
    are taken up by the repetitive `hc{r,t}x->ccid{2-4}_hc_{r,t}x_';

 2/ there are many expressions which involve computations involving
    two and more field members. This almost inevitably creates
    unwieldy multiline expressions.

These structs affect a subset of DCCP only, and are always preceded 
either by "hctx->..." or "hcrx->...". This is a consistent convention.

With regard to being greppable,
 * cscope was found to work with the short identifiers,
 * have not tested ctags, here it may indeed be that there
   are multiple matches,
 * most of the source code is confined to net/dccp (the only
   exception is include/linux/{dccp,tfrc}.h).
 
These two patches didn't come out of a personal whim: over the past
6 months this was discussed several times on dccp@vger, each time
people confirmed that the identifiers were too long. There was clear
agreement in this regard.

If you still find the above unacceptable with regard to the policy,
is there an alternative/compromise which would satisfy both goals?

Gerrit
