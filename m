From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [SCTP]: Prevent possible infinite recursion with
 multiple bundled DATA.
Date: Fri, 05 May 2006 17:04:17 -0700 (PDT)
Message-ID: <20060505.170417.47696523.davem@davemloft.net>
References: <1146856478.7861.34.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41421
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751084AbWEFAER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 20:04:17 -0400
To: sri@us.ibm.com
In-Reply-To: <1146856478.7861.34.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 05 May 2006 12:14:38 -0700

> [SCTP]: Prevent possible infinite recursion with multiple bundled DATA.
> 
> There is a rare situation that causes lksctp to go into infinite recursion
> and crash the system.  The trigger is a packet that contains at least the
> first two DATA fragments of a message bundled together. The recursion is
> triggered when the user data buffer is smaller that the full data message.
> The problem is that we clone the skb for every fragment in the message.
> When reassembling the full message, we try to link skbs from the "first
> fragment" clone using the frag_list. However, since the frag_list is shared
> between two clones in this rare situation, we end up setting the frag_list
> pointer of the second fragment to point to itself.  This causes
> sctp_skb_pull() to potentially recurse indefinitely.
> 
> Proposed solution is to make a copy of the skb when attempting to link
> things using frag_list.
> 
> Signed-off-by: Vladislav Yasevich <vladsilav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, but again I had to manually remove a ton of trailing
whitespace added by this patch.

