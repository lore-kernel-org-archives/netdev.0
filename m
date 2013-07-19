From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: is the work queue is initialized at wrong place?
Date: Fri, 19 Jul 2013 08:10:17 +0200
Message-ID: <20130719061017.GA3334@electric-eye.fr.zoreil.com>
References: <5838023.rAHnY47tlv@al>
 <20130718215343.GA25075@electric-eye.fr.zoreil.com>
 <2387149.B9WVEQm2aY@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40917 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693Ab3GSGK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 02:10:27 -0400
Content-Disposition: inline
In-Reply-To: <2387149.B9WVEQm2aY@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
> On Thursday 18 July 2013 23:53:43 Francois Romieu wrote:
[...]
> > (or cancel_work_sync in rtl8169_close to reduce the scope)
> Will this also work with multiple adapters? I currently have an on-board chip 
> using the r8169 driver and a separate PCI card.

As stated by David, yes.

> > I do not see how the current code could hurt but it's really ugly.
> When I googled for the warning, I found some hint about something not being 
> initialized. From that I guessed that rtl_open is never called when the 
> network interface is not brought up (which seems to match the documentation of 
> struct net_device_ops[1]).

You guessed right. Please note that the relevant struct is zeroed during
initialization (see net/core/dev.c::alloc_netdev_mqs). While it's true
that the struct is not initialized for use by the device, cancel_work_sync
will cope with it (bail out thanks to a 0 bitflag).

You can ignore the warning and proceed with the driver as-is.

I'll fix it anyway. It's too ugly to be kept as is.

Side-note: if you can publish your eeprom reading code, it would be
interesting to know how it differs from what has already been tried
in the past.

-- 
Ueimor
