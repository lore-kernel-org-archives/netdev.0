From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] support for IEEE 1588
Date: Thu, 3 Jul 2008 16:24:28 -0700
Message-ID: <20080703162428.55d9f345@extreme>
References: <200807040147.11148.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59683 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950AbYGCXYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 19:24:36 -0400
In-Reply-To: <200807040147.11148.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Jul 2008 01:47:11 +0300
Octavian Purdila <opurdila@ixiacom.com> wrote:

> 
> Hi everybody,
> 
> IEEE 1588 Precision Time Protocol [1] requires hardware timestamping support 
> for both RX and TX frames. It seems that in Linux we do not have the support 
> required for this protocol to be implemented. 
> 
> Any feedback on the approach we are planing to take is greatly appreciated. We 
> will follow with a patch at some point, but I just want to check with you 
> gurus early, to avoid potential design flaws. If a patch is preferred for 
> commenting on, then please ignore this and will come back later with the 
> patch.
> 
> 1. RX path
> - add a new field in skb to keep the hardware stamp (hwstamp)
> - add a new socket flag to enable RX stamping 
> - add a new control message to retrieve the hwstamp from the skb to user-space 
> application (for UDP and maybe PF_PACKET)

The existing skb timestamp is there, and if the hardware supports it, it could
be updated by the device driver  I had a version of sky2 that did just that
but never fully pushed it upstream because of available time and testing issues.

The API's are already there (and used) for timestamping; don't invent
new ones.
