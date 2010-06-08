From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: [PATCH][RFC] Check sk_buff states
Date: Mon, 7 Jun 2010 21:46:10 -0700
Message-ID: <EB1E9C2D-55C5-4B57-A98D-E195309E9E05@earthlink.net>
References: <20100608003055.GA29405@dvomlehn-lnx2.corp.sa.net>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David VomLehn <dvomlehn@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:57008 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750959Ab0FHEqM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jun 2010 00:46:12 -0400
In-Reply-To: <20100608003055.GA29405@dvomlehn-lnx2.corp.sa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 7, 2010, at 5:30 PM, David VomLehn wrote:

> This uses the oobparam and callsite infrastructure to implement sk_buff
> state checking and error reporting. Possible states of an sk_buff are:
> 	SKB_STATE_FREE - Is not currently in use
> 	SKB_STATE_ALLOCATED - Has been allocated, but is not on a queue
> 	SKB_STATE_QUEUED - Is allocated and on a queue
> Since there are only three states, two bits suffice to record the state of
> an sk_buff structure, so checking for consistent state is easy. (For you
> weenies, the fourth possible state *is* flagged as an error).


... cut...

Just my two cents,
Just initially thinking of the state names & using only two bits
If a 3rd bit, then it could indicate exclusive or shared (double free then acceptable if shared)

kmem_alloc, malloc, etc actually allocate structs
when something is allocated but not associated with anything, then it has no reference

so then why not?

xxx_STATE_INVALID:		both bits unset
xxx_STATE_ALLOCATED:     bit 0 set and bit 1 not set
xxx_STATE_REFERENCED : could be exclusive or shared, bit 0 unset & bit 1 set
xxx_STATE_QUEUED:           both bits set

Mitchell Erblich



