From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/34]bnx2x: Bug fixes
Date: Wed, 14 Jan 2009 21:36:22 -0800 (PST)
Message-ID: <20090114.213622.242296202.davem@davemloft.net>
References: <1231951356.11301.121.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pl@linux.vnet.ibm.com, yanivr@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50326
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752941AbZAOFgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:36:21 -0500
In-Reply-To: <1231951356.11301.121.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Jan 2009 18:42:35 +0200

> The problem is that more and more bugs required immediate attention so
> the result is a long list of bug fixes.

You have to understand that you absolutely cannot slap me with 34 "bug
fixes" all at once after the merge window is closed.

> Please consider applying.

I've gone through patches 1 to 17 for now.  Patched I didn't apply:

1) [PATCH 02/34]bnx2x: Barriers for the compiler

   Need feedback on my query, if this requires a compiler barrier
   it almost certainly needs cpu reordering barriers too.

2) [PATCH 05/34]bnx2x: Setting the GSO_TYPE with LRO

   As discussed at length, this isn't correct and it's not the
   way to fix this problem.  Implement the ethtool LRO disable
   and the kernel will turn it off when bridging or routing is
   being used over this interface.

3) [PATCH 10/34]bnx2x: Compilation issue on IA64

   This code is ugly and even in the worst case the thing to do
   is unconditionally use "%llx" and cast the arg to "long long"
   to kill the warning.

4) [PATCH 13/34]bnx2x: System cache alignment

   This is an optimization and has no business going in outside
   of the merge window.

I'll go over the rest after I send what I have now to Linus, but don't
set your expectations high, this is way too many patches to be sending
now.

