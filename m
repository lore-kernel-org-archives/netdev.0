From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Regression: non-working WOL with r8169
Date: Sat, 8 Oct 2011 01:28:35 +0200
Message-ID: <20111007232834.GA29770@electric-eye.fr.zoreil.com>
References: <20111007221906.810698ba9bf825566a2478bb@gmx.de> <20111007210017.GA27820@electric-eye.fr.zoreil.com> <20111007214200.GA28365@electric-eye.fr.zoreil.com> <20111008003156.ef4dfaa76576ca8079edfbb9@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, netdev@vger.kernel.org
To: Marc Ballarin <ballarin.marc@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54346 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370Ab1JGXar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 19:30:47 -0400
Content-Disposition: inline
In-Reply-To: <20111008003156.ef4dfaa76576ca8079edfbb9@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Ballarin <ballarin.marc@gmx.de> :
[...]
> CONFIG_PM is set, but the way the system is shut down seems to be an issue
> indeed.
> 
> WOL works after echo mem > /sys/power/state (but then the system crashes,
> but this is a separate issue).
> 
> But it does not work after halt/shutdown -h now.

How surprizing... :o/

pci_driver.shutdown - aka rtl_shutdown - uses rtl8169_hw_reset and
stomps on RxConfig without further care when something similar to
r8168_pll_power_down is needed.

I'll dig it during the week end.

-- 
Ueimor
