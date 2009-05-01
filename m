From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] qos: Limit a filter's priority to a 16 bit value
Date: Fri, 01 May 2009 15:51:55 -0700 (PDT)
Message-ID: <20090501.155155.58484825.davem@davemloft.net>
References: <20090501184242.12714.2663.stgit@fritz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: robert.w.love@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60652
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751848AbZEAWwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:52:01 -0400
In-Reply-To: <20090501184242.12714.2663.stgit@fritz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Love <robert.w.love@intel.com>
Date: Fri, 01 May 2009 11:42:42 -0700

> Currently the kernel is storing the priority value for
> a filter as a 32 bit value. However, the netlink messages
> between the kernel and userspace are passing only 16 bits
> for the priority. This means that the kernel will always
> try to compare the passed down filter's priority using the
> correct upper 16 bits, but all 0s for the lower 16 bits.
> 
> Most comparisons will fail when checking against the filter
> chain unless the actual filter has a priority with all 0s
> for the last 16 bits.
> 
> The fallout is that users cannot modify or delete most
> filters that are added.

Really?

I'm looking at the code and I don't see this failure case.
Can you describe the problem with specific examples?

All of the code I see either 1) uses u32's to store the
priorities and just compares them (cls_u32.c) or 2)
always uses TC_H_MAJ() of the user's provided value
and uses that to compare with tp->prio values.

Both of which should always just work.

We're just wasting the low 16-bits, but that shouldn't
cause problems like the one you're describing as long
as everyone extracts and compares the top bits properly
which as far as I can tell is the case.
