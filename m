From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH][RFC] Check sk_buff states
Date: Tue, 8 Jun 2010 11:28:11 -0700
Message-ID: <20100608182811.GA31503@dvomlehn-lnx2.corp.sa.net>
References: <20100608003055.GA29405@dvomlehn-lnx2.corp.sa.net> <EB1E9C2D-55C5-4B57-A98D-E195309E9E05@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:45422 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007Ab0FHS2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 14:28:13 -0400
Content-Disposition: inline
In-Reply-To: <EB1E9C2D-55C5-4B57-A98D-E195309E9E05@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 07, 2010 at 11:46:10PM -0500, Mitchell Erblich wrote:
> 
> On Jun 7, 2010, at 5:30 PM, David VomLehn wrote:
> 
> > This uses the oobparam and callsite infrastructure to implement sk_buff
> > state checking and error reporting. Possible states of an sk_buff are:
> > 	SKB_STATE_FREE - Is not currently in use
> > 	SKB_STATE_ALLOCATED - Has been allocated, but is not on a queue
> > 	SKB_STATE_QUEUED - Is allocated and on a queue
> > Since there are only three states, two bits suffice to record the state of
> > an sk_buff structure, so checking for consistent state is easy. (For you
> > weenies, the fourth possible state *is* flagged as an error).
> 
> 
> ... cut...
> 
> Just my two cents,
> Just initially thinking of the state names & using only two bits
> If a 3rd bit, then it could indicate exclusive or shared (double free then acceptable if shared)
> 
> kmem_alloc, malloc, etc actually allocate structs
> when something is allocated but not associated with anything, then it has no reference
> 
> so then why not?
> 
> xxx_STATE_INVALID:		both bits unset
> xxx_STATE_ALLOCATED:     bit 0 set and bit 1 not set
> xxx_STATE_REFERENCED : could be exclusive or shared, bit 0 unset & bit 1 set
> xxx_STATE_QUEUED:           both bits set
> 
> Mitchell Erblich

I think adding a bit is no problem, but the description is a bit too terse
for me.  The distinction between allocated and referenced wasn't clear
enough that I could figure out which skb_* functions affect this.
-- 
David VL
