From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv2 RFC net-next] net/vxlan: Fix kernel unaligned access
 in __vxlan_find_mac
Date: Sun, 19 Jul 2015 12:07:02 -0700
Message-ID: <1437332822.24289.19.camel@perches.com>
References: <20150717.181825.641987192390100037.davem@davemloft.net>
	 <1437242786.24289.11.camel@perches.com> <55AB919E.8030505@oracle.com>
	 <20150719.113834.2117166333832979820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0145.hostedemail.com ([216.40.44.145]:52823 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753562AbbGSTHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2015 15:07:06 -0400
In-Reply-To: <20150719.113834.2117166333832979820.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-07-19 at 11:38 -0700, David Miller wrote:
> From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Date: Sun, 19 Jul 2015 14:01:34 +0200
> 
> > On 07/18/2015 08:06 PM, Joe Perches wrote:
> > 
> >> It seems that this code has had unaligned accesses
> >> on this field even before compare_ether_addr was
> >> converted to ether_addr_equal.
> >>
> >> Is sparc64 the only one that emits / ratelimits that
> >> unaligned access message?  I looked a little, but I
> >> didn't find a fixup message when MIPS does unaligned
> >> accesses.  Are all the other arches silent when
> >> fixing up unaligned accesses?  Maye adding a generic
> >> debug only ratelimited message might help remove
> >> more of these.  As it's not fatal, naybe the sparc64
> >> message should be KERN_DEBUG/pr_debug.
> > 
> > I'm confused, are we suggesting that we "fix" the unaligned
> > access by snuffing out the message that complains loudly and correctly
> > about it?
> > 
> > See also: large block comment above __pksb_trim
> > about correctly using skb_reserve(). Evidently not being
> > correctly done for the IPv6-vxlan code path (and possibly
> > for other encaps too?)
> 
> We should fix the unaligned accesses, rather than quiet the
> warning.

Definitely so, the question I have is whether or not the the
message should be able to be silenced, not just ratelimited.

I think there are likely to be occasions when, given arbitrary
protocol stacking, unaligned accesses are unavoidable.

Perhaps batman might have this as an actual issue.
