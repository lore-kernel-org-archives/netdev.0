From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: hardware time stamping with extra skb->hwtstamp
Date: Fri, 28 Nov 2008 18:00:09 +0200
Message-ID: <200811281800.09870.opurdila@ixiacom.com>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com> <200811281455.32744.opurdila@ixiacom.com> <49301068.8090401@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Patrick Ohly <patrick.ohly@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:24231 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751158AbYK1QEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 11:04:42 -0500
In-Reply-To: <49301068.8090401@hartkopp.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Fri, 28 Nov 2008 16:38:16 +0100


> Do you know what all the people are doing with skbuffs in the kernel?
> I'm not aware of it.
> So whenever we touch a vital data structure like the skbuff we must be
> sure that our handling is a wise approach for all.

I agree. But what in this approach do you think its not wise? :)

The skb is not touched at all, we just need to allocate a larger skb when 
using hw timestamps (or other extensions) and reserve some portion of it. 

> Btw. your answer brought me to a completely different approach:
>
> What about just creating a new pointer in the struct skbuff that points
> to a struct hwstamp when it is available OR the pointer is NULL when no
> hwstamps are available.
> This struct hwstamp may consist of 'everthing we really need for
> timestamping' and is added somewhere at the head or the tail of the
> skbuff data section by the device driver.
> And if the socket sees this pointer to be not NULL it knows where to
> look for our fancy struct hwstamp ...
>
> I don't know, where this hwstamp data could be pasted into the data
> section in the best way - but surely others know. Especially this
> approach meets the requirement that the additional hwstamp data is only
> allocated (per interface!), when it's really needed - and not for
> everyone by default.
>
> What do you thing about this idea?
>

That is still adding a member into the skb. For what I am proposing we don't 
have to touch the skb and it has all of your approach benefits. 

I would rather use this approach since it allows us to "extend" the skb in 
this manner int the future for other hardware features which requires passing 
per-skb information to userspace.

Thanks,
tavi




