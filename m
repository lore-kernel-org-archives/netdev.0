From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: query : unregister/register netdev
Date: Fri, 18 Nov 2011 08:22:00 -0800
Message-ID: <20111118082200.2c973d0c@nehalam.linuxnetplumber.net>
References: <CAAvRe=jhfXEnLFkwbPmWEroDE-qHUpZ54TSSdw=WpmfPGZpsPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Madhvapathi Sriram <sriram.madhvapathi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60584 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753376Ab1KRQWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Nov 2011 11:22:03 -0500
In-Reply-To: <CAAvRe=jhfXEnLFkwbPmWEroDE-qHUpZ54TSSdw=WpmfPGZpsPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Nov 2011 17:53:37 +0530
Madhvapathi Sriram <sriram.madhvapathi@gmail.com> wrote:

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

There are two reasons. First because of RCU the device object still might
be in use after unregister (until after RCU quiescent period). But the real
reason is that no device driver existing needed it. The normal use case
of unregister is when device is being removed or session for a virtual device
is going away.
