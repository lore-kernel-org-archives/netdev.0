From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCHv2 RFC net-next] net/vxlan: Fix kernel unaligned access
 in __vxlan_find_mac
Date: Sun, 19 Jul 2015 14:01:34 +0200
Message-ID: <55AB919E.8030505@oracle.com>
References: <20150717200031.GB30336@oracle.com>	 <1437174422.2495.75.camel@perches.com>	 <20150717.181825.641987192390100037.davem@davemloft.net> <1437242786.24289.11.camel@perches.com>
Reply-To: sowmini.varadhan@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30886 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067AbbGSMBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2015 08:01:45 -0400
In-Reply-To: <1437242786.24289.11.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/2015 08:06 PM, Joe Perches wrote:

> It seems that this code has had unaligned accesses
> on this field even before compare_ether_addr was
> converted to ether_addr_equal.
>
> Is sparc64 the only one that emits / ratelimits that
> unaligned access message?  I looked a little, but I
> didn't find a fixup message when MIPS does unaligned
> accesses.  Are all the other arches silent when
> fixing up unaligned accesses?  Maye adding a generic
> debug only ratelimited message might help remove
> more of these.  As it's not fatal, naybe the sparc64
> message should be KERN_DEBUG/pr_debug.

I'm confused, are we suggesting that we "fix" the unaligned
access by snuffing out the message that complains loudly and correctly
about it?

See also: large block comment above __pksb_trim
about correctly using skb_reserve(). Evidently not being
correctly done for the IPv6-vxlan code path (and possibly
for other encaps too?)

--Sowmini
