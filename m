From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 vpd r/w failed
Date: Fri, 1 Jun 2012 01:49:55 +0200
Message-ID: <20120531234955.GA4007@electric-eye.fr.zoreil.com>
References: <20120531174126.GA4189@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57289 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932509Ab2EaX6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 19:58:30 -0400
Content-Disposition: inline
In-Reply-To: <20120531174126.GA4189@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones <davej@redhat.com> :
[...]
>  We occasionally see reports from r8169 where it seems to hang
> reading vpd data from the NIC. The printk in drivers/pci/
> suggests it's likely a firmware bug on the device, and recommends the user
> contact the vendor for an update (does Realtek even do firmware updates?)
> 
> Is this as the message suggests a firmware bug, or should r8169 be
> avoiding trying to read vpd ?

I have not practiced vpd with the 816x a lot but I have experienced an
unlimited read behavior with the 8168 while trying to access the vpd back
in march. The output exhibited a periodic pattern, so I got rid of
it with something similar to drivers/pci/quirks.c::quirk_brcm_570x_limit_vpd.

I can resurrect it but I'd rather give the pending softirq stuff a try
first and I must test davandra netif_napi_del patch as well. Btw I have
just upgraded my workstation to F17 and it's time for some sleep.

> https://bugzilla.redhat.com/show_bug.cgi?id=827137 is one example.

(990FX)

Adding a RTL_GIGA_MAC_VER_34 case similar to RTL_GIGA_MAC_VER_24 in
rtl_init_rxcfg may temporarily help if netdev watchdog triggers (see
the mess known as https://bugzilla.kernel.org/show_bug.cgi?id=42899).

-- 
Ueimor
