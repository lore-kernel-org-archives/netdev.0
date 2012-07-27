From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169, 3.5.0, does't work at all
Date: Fri, 27 Jul 2012 11:13:19 +0200
Message-ID: <20120727091319.GA27071@electric-eye.fr.zoreil.com>
References: <88f2e8e7f795239ec4bc759dcda61665@visp.net.lb> <20120726195658.GA14668@electric-eye.fr.zoreil.com> <e9e38770b95bc3664fdc642fdfb65a13@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44190 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565Ab2G0J0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 05:26:41 -0400
Content-Disposition: inline
In-Reply-To: <e9e38770b95bc3664fdc642fdfb65a13@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko <denys@visp.net.lb> :
[...]
> and i can search for more machines with similar cards.

Thanks.

There seems to be a more recent bios for this motherboard. Is the second
8168b an add-on or is it a dual-port DH61HO ?

You are using x86 32 with PAE and slub where I use x86 64 with slab.
I am building a x86 32 bits test configuration for a 8168b right now.

Let's see what happened during the 3.4 .. 3.5 cycle in the r8169 driver:

- You may revert 7dbb491878a2c51d372a8890fa45a8ff80358af1 ("r8169: avoid NAPI
  scheduling delay.")

  I can see a napi rtl8169_poll failing to schedule rtl_slow_event_work
  when it is already scheduled on a different cpu, said rtl_slow_event_work
  running while rtl8169_poll is delayed and rtl8169_poll stomping on the
  IntrMask after rtl_slow_event_work did.

  It does not tell why the device does not recover after the netdev watchdog
  but it could be worth trying.

- You may revert 851e60221926a53344b4227879858bef841b0477 ("r8169: Config1 is
  read-only on 8168c and later.") as well.

  It changes the PMEEnable write ordering for the 8168b (RTL_GIGA_MAC_VER_17)
  and a few others chipset.

-- 
Ueimor
