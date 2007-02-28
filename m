From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Wed, 28 Feb 2007 10:22:31 -0800
Message-ID: <20070228102231.05461589@localhost>
References: <45E5570E.7050301@free.fr>
	<45E585AD.8050704@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org,
	linux.kernel@free.fr
To: John <linux.kernel@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37829 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932203AbXB1SWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 13:22:34 -0500
In-Reply-To: <45E585AD.8050704@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Feb 2007 14:37:49 +0100
John <linux.kernel@free.fr> wrote:

> John wrote:
> 
> > I know it's possible to have Linux timestamp incoming datagrams as soon
> > as they are received, then for one to retrieve this timestamp later with
> > an ioctl command or a recvmsg call.
> 
> Has it ever been proposed to modify struct skb_timeval to hold 
> nanosecond stamps instead of just microsecond stamps? Then make the 
> improved precision somehow available to user space.
> 

I am playing with a couple of possible future changes.
1. Change skb timestamp to be a timespec instead of timeval, for ABI
   compatiablity the existing SO_TIMESTAMP has to stay microseconds,
   but add a new SO_TIMESPEC to get the nanosecond version.

   The change gets non trivial because of other uses of timestamp (like vegas)
   so I gave up for now.

2. Use hardware receive timestamp in Yukon2 to put actual receive time
   into skb timestamp.  Works, but still figuring out how to manage
   clock skew/resync.
