From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v5] bfin_mac: convert bfin Ethernet driver to NAPI
 framework
Date: Fri, 18 Jul 2014 00:29:06 +0200
Message-ID: <20140717222906.GA23125@electric-eye.fr.zoreil.com>
References: <1405504302-21344-1-git-send-email-sonic.adi@gmail.com>
 <1405516649.10255.59.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140716.140301.896018835447121717.davem@davemloft.net>
 <CAJxxZ0OybvReRHvRuL84N=25T6cRG8k1j_gXLcu7U6jHvSZ5Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Varka Bhadram <varkabhadram@gmail.com>,
	adi-buildroot-devel@lists.sourceforge.net,
	"Zhang, Sonic" <sonic.zhang@analog.com>
To: Sonic Zhang <sonic.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45310 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756634AbaGQW3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 18:29:22 -0400
Content-Disposition: inline
In-Reply-To: <CAJxxZ0OybvReRHvRuL84N=25T6cRG8k1j_gXLcu7U6jHvSZ5Tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sonic Zhang <sonic.adi@gmail.com> :
> On Thu, Jul 17, 2014 at 5:03 AM, David Miller <davem@davemloft.net> wrote:
[...]
> > Please mimick what other drivers do rather than trying to do things in
> > a special way unique to your driver.
> 
> Driver realtek/8139cp.c does things in the same way as the bfin_mac
> NAPI code.

It wasn't your lucky day.

> In net_poll loop, if napi_complete() is called, the EMAC IRQ is
> enabled more times than the it is disabled. This is not a problem to
> drivers which don't call enable_irq()/disable_irq_nosync(). But, the
> IRQ enabling and disabling operations have to be balanced in the
> bfin_mac driver via __napi_complete() to avoid the kernel warning.

Thanks for the explanation.

In order to use plain napi_complete, may I suggest keeping a mask of
bfin_mac_interrupt disabled irq in the device private area then
enable_irq relevant one - if any - in bfin_mac_poll ?

It should keep things balanced.

-- 
Ueimor
