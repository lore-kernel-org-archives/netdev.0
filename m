From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] r8169: fix a race between PCI probe and dev_open
Date: Wed, 31 Jan 2007 16:55:55 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0701311655050.3632@woody.linux-foundation.org>
References: <20070131213428.GA17534@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	jgarzik@pobox.com, Bernhard Walle <bwalle@suse.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34356 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161141AbXBAA4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 19:56:11 -0500
In-Reply-To: <20070131213428.GA17534@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 31 Jan 2007, Francois Romieu wrote:

> Call chain:
> -> rtl8169_init_one
>    -> register_netdev                  (dev_open starts to race...)
>    -> rtl8169_init_phy
>       -> rtl8169_set_speed
>          -> tp->set_speed
>          -> mod_timer(&tp->timer, ...) (if netif_running() is true)
> 
> As netif_running() is true just before dev->open() is issued and the
> timer is initialized during dev->open, mod_timer() meets an uninitialized
> tp->timer and oopses.

Doesn't this basically mean that *any* use of "rtl8169_set_speed()" is 
buggy?

Anyway, I'm going to wait for somebody smarter than me to ACK this patch. 
Jeff?

		Linus
