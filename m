From: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix broken register writes
Date: Mon, 29 Mar 2010 23:11:16 +0200
Message-ID: <20100329211115.GA3251@electric-eye.fr.zoreil.com>
References: <4BAE6C92.2060801@iki.fi>
 <20100327211133.GA3624@electric-eye.fr.zoreil.com>
 <1269732054.8653.155.camel@localhost>
 <20100327.163005.28815553.davem@davemloft.net>
 <20100328003143.GA8501@electric-eye.fr.zoreil.com>
 <1269737245.8653.162.camel@localhost>
 <20100328212858.GA4220@electric-eye.fr.zoreil.com>
 <20100328221924.GG30031@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	ivecera@redhat.com, netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 55.58.140-88.rev.gaoland.net ([88.140.58.55]:53768 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752768Ab0C2VNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 17:13:45 -0400
Content-Disposition: inline
In-Reply-To: <20100328221924.GG30031@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro <viro@ZenIV.linux.org.uk> :
[...]
> FWIW, XID18000000 here (J7F4) loses MAC4 on shutdown; hadn't tested the patch
> yet.  2.6.26 (on that box) and 2.6.31 (on identical mb) work, 2.6.33 doesn't.
> I suspect that bisect would lead to commit cc098dc70 (i.e. the place where we
> started to set address on shutdown).  One more data point: ifconfig hw ether
> done under 2.6.26 did restore the address.  And that's the same function,
> isn't it?

You are right.

> Another interesting bit: unlike the older kernel, grep for eth0 in .33 dmesg
> 
> eth0: RTL8169sc/8110sc at 0xf87fc000, 00:30:18:a4:65:89, XID 18000000 IRQ 18
> r8169: eth0: link down
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> r8169: eth0: link up
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

Remove rtl8169scd_hw_phy_config ?

[...]
> Same for .31 on another box, modulo different address there...

No, keep it.


At first sight it looks like rtl8169_open::rtl8169_check_link_status and
a LinkChg interrupt (order eventually reversed) while 2.6.26 did not
notice the interrupt.

-- 
Ueimor
