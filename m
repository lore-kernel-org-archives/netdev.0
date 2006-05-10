From: "David S. Miller" <davem@davemloft.net>
Subject: Re: possible problem with TSO and ip_queue
Date: Wed, 10 May 2006 12:49:55 -0700 (PDT)
Message-ID: <20060510.124955.114056211.davem@davemloft.net>
References: <Pine.LNX.4.64.0605101815430.16614@nacho.alt.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	paul@clubi.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46991
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751327AbWEJTud (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 15:50:33 -0400
To: ccaputo@alt.net
In-Reply-To: <Pine.LNX.4.64.0605101815430.16614@nacho.alt.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Caputo <ccaputo@alt.net>
Date: Wed, 10 May 2006 18:44:30 +0000 (GMT)

> Does this sound like a bug or by design?
> 
> Does it make sense that ip_queue mangled packets be subjected to TSO, 
> given that the TCP header can be messed with by the user mode code?

This is by design.  Netfilter looks at full TSO frames, but the
TSO hardware in the cards do not interpret the TCP options in any
way whatsoever when splitting the TSO packet up into MSS frames,
they just copy the options as-is into each sub-frame.

Once you add MD5 checksums to the TCP packet, TSO can no longer be
used on that path, so you'll have to disable TSO either in the route
or via some other means.
