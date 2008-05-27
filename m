From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 19:22:34 +0400
Message-ID: <20080527152234.GA16419@2ka.mipt.ru>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527132148.GA7368@2ka.mipt.ru> <20080527140318.GA6963@2ka.mipt.ru> <200805271739.11612.opurdila@ixiacom.com> <20080527150931.GA23415@2ka.mipt.ru> <20080527151259.GA11862@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54253 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755895AbYE0PWm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 11:22:42 -0400
Content-Disposition: inline
In-Reply-To: <20080527151259.GA11862@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2008 at 07:12:59PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Tue, May 27, 2008 at 07:09:31PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > Please test this one assuming there are no other patches applied before.
> 
> A typo sneaked into the patch, please try this one.

The same wrong one, sorry about that.

Idea is to hold skb between release/lock sock calls and thus do not
allow to free it by core stack when it is being released. Patch still
misses the case, when socket is released and skb was dequeued, so splice
will try to dequeue it again, which will crash. I will think on how to
fix the issue.

-- 
	Evgeniy Polyakov
