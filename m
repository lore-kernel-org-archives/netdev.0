From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH][RFC] Check sk_buff states
Date: Wed, 9 Jun 2010 11:07:18 -0700
Message-ID: <20100609180718.GA19804@dvomlehn-lnx2.corp.sa.net>
References: <20100608003055.GA29405@dvomlehn-lnx2.corp.sa.net> <878w6o65kx.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:55292 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991Ab0FISH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 14:07:29 -0400
Content-Disposition: inline
In-Reply-To: <878w6o65kx.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 09, 2010 at 02:14:06AM -0500, Andi Kleen wrote:
> David VomLehn <dvomlehn@cisco.com> writes:
> >
> > Some of the errors that can be detected are:
> > o	Double-freeing an skb_buff
> 
> slab debugging should already catch that (although at higher cost)

There is a sublety here--if skb_clone() is used, skb_free() isn't
necessarily called until both parts of the cloned sk_buff are no longer
used. But it's not just that the double free is called, it's that you
also know where the first free is located. This turns out to be very
valuable.

> I would say the big question is how many bugs such a new infrastructure
> find. Did you find any?

Definitely. I've heard back about two cases. One of them was especially
gratifying because it has a control case. Two people were looking for the
same bug and found it within hours of each other. One person, who didn't
have the code enabled, took three weeks. The other person enabled the code.
It took him three hours to find the problem. So, our networking people
have been very happy to have this.

> -Andi

-- 
David VL
