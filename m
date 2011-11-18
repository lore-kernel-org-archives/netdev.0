From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: query : unregister/register netdev
Date: Fri, 18 Nov 2011 15:52:06 +0000
Message-ID: <1321631526.2885.121.camel@deadeye>
References: <CAAvRe=jhfXEnLFkwbPmWEroDE-qHUpZ54TSSdw=WpmfPGZpsPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Madhvapathi Sriram <sriram.madhvapathi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31987 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757869Ab1KRPwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 10:52:15 -0500
In-Reply-To: <CAAvRe=jhfXEnLFkwbPmWEroDE-qHUpZ54TSSdw=WpmfPGZpsPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-11-18 at 17:53 +0530, Madhvapathi Sriram wrote:
> Hi,
> 
> In register_netdevice(), BUG_ON(dev->reg_state != NETREG_UNINITIALIZED) is
> used to check if the device that is being registered is indeed a new one.
> 
> However, I see that this state is never moved to. It only happens when a
> netdevice is allocated (by default to 0 using kzalloc).
> 
> So, the cycle register-->unregister-->register would fail since in the
> unregister_netdevice the state is only moved to NETREG_UNREGISTERED (at max
> to NETREG_RELEASED using free_netdev)
> 
> So, I presume that to reinitialize a netdevice one has to free the
> netdevice, re allocate netdevice and only then re register.
> 
> Wondering why unregister and reregister is not allowed, rather than having
> go through the free/alloc cycle - I am not an expert though.

Why do you think that would be useful?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
