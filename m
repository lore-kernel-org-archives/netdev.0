From: David Dillow <dave@thedillows.org>
Subject: Re: [RFC 2.6.10 1/22] xfrm: Add direction information to xfrm_state
Date: Sat, 22 Jan 2005 00:50:22 -0500
Message-ID: <1106373022.3691.36.camel@ori.thedillows.org>
References: <20041230035000.01@ori.thedillows.org>
	 <20041230035000.10@ori.thedillows.org>
	 <20050121143857.69282605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050121143857.69282605.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-01-21 at 14:38 -0800, David S. Miller wrote: 
> On Thu, 30 Dec 2004 03:48:34 -0500
> David Dillow <dave@thedillows.org> wrote:
> 
> > # This is a BitKeeper generated diff -Nru style patch.
> > #
> > # ChangeSet
> > #   2004/12/30 00:27:15-05:00 dave@thedillows.org 
> > #   Add direction information to xfrm_state. This will be needed to
> > #   offload xfrm processing to the NIC.
> 
> And xfrm_state, when actually used, does not exist in a vacuum.
> It is being used in terms of a particular xfrm_policy which has
> a direction indicator already.
> 
> Given that, it seems the xfrm_state is not only unnecessary, but
> also slightly illogical in fact.  If you need the direction, you
> should make sure that at those places you can get back to the
> policy in order to obtain that piece of information.

Hmm, I can see having netdev->xfrm_bundle_add() assume a outbound state,
since it's only called for Tx.

Rx offloading could be interesting, but it looks like I could hook into
net/xfrm/xfrm_policy.c:__xfrm_policy_check(), and add the xfrm_states
seen there to a work queue for offloading. netdev->xfrm_state_add()
would then only see inbound states.

Sound sane?
-- 
David Dillow <dave@thedillows.org>
