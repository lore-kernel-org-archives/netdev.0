From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe: normalize frag_list usage
Date: Wed, 06 Oct 2010 23:58:37 -0700 (PDT)
Message-ID: <20101006.235837.241424681.davem@davemloft.net>
References: <4CAA1722.7070405@intel.com>
	<20101004.113258.212671454.davem@davemloft.net>
	<80769D7B14936844A23C0C43D9FBCF0F25B97A24B5@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54722
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752779Ab0JGG6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 02:58:16 -0400
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F25B97A24B5@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Tue, 5 Oct 2010 15:45:32 -0700

> The patch below is kind of what I had in mind for a way to do RSC and maintain
> the pointer scheme you are looking for.  Consider this patch an RFC for now
> since I based this off of Jeff's internal testing tree and so it would need
> some modification to apply cleanly to net-next.

Can you really not remember the head somewhere?

What I wanted is for everyone to build their frag list SKBs from head to tail,
always.  So that I could, as I mentioned in my original posting, do something
like:

struct sk_buff {
	union {
		struct list_head list;
		struct {
			struct sk_buff	*frag_next;
			struct sk_buff	*frag_tail_tracker;
		};
	};
};

The ->frag_tail_tracker is only used in the head SKB to maintain where the
last SKB in the frag list is.

You're tracking the head from the inner SKBs, such that my intended
conventions are not being followed.
