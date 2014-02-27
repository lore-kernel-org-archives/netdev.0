From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 0/7] Non-promisc bidge ports support
Date: Thu, 27 Feb 2014 09:20:06 +0200
Message-ID: <20140227072006.GD16484@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
 <530E7FE1.5060705@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750724AbaB0HOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 02:14:46 -0500
Content-Disposition: inline
In-Reply-To: <530E7FE1.5060705@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 26, 2014 at 06:59:29PM -0500, Jamal Hadi Salim wrote:
> On 02/26/14 10:18, Vlad Yasevich wrote:
> >This patch series is a complete re-design and re-implementation of
> >prior attempts to support non-promiscuous bridge ports.
> >
> >The basic design is as follows.  The bridge keeps track of
> >all the ports that flood packets to unknown destinations.  If
> >the flooding is disabled on the port, to get traffic to flow
> >through, user/management would need to add an fdb describing
> >such traffic.  When such fdb is added, we save the address
> >to bridge private hardware address list.
> 
> Entering the addresses in the uc list on other bridgeports seems
> reasonable for the scenario described.
> But would it _also_ need to be added to the fdb of the bridge?
> i.e how does the bridge (if the packet was to be handed to it)
> know where to forward?
> BTW: on the comment that flooding off implies learning off: I would like
> to be able to turn off flooding on a specific bridge port but
> still want to learn from it. I dont think those two are mutually
> exclusive.
> 
> cheers,
> jamal

I agree.

It seems a reasonable tradeoff to limit any specific
optimization to !flood && !learn if this simplifies the
implementation significantly and if everything works
as it did before even with learning on.


-- 
MST
