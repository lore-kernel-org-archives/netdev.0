From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: fix regression from patch "Add ethtool WOL
 support"
Date: Mon, 27 Sep 2010 11:08:03 -0700 (PDT)
Message-ID: <20100927.110803.220069414.davem@davemloft.net>
References: <4CA09E2D0200007800019050@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@beldisplaytech.com, netdev@vger.kernel.org
To: JBeulich@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41330
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757165Ab0I0SHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:07:43 -0400
In-Reply-To: <4CA09E2D0200007800019050@vpn.id2.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@novell.com>
Date: Mon, 27 Sep 2010 12:37:49 +0100

> This patch (commit 690a1f2002a3091bd18a501f46c9530f10481463) added a
> new call site for acpi_set_WOL() without checking that the function is
> actually suitable to be called via
> 
>  vortex_set_wol+0xcd/0xe0 [3c59x]
>  dev_ethtool+0xa5a/0xb70
>  dev_ioctl+0x2e0/0x4b0
>  T.961+0x49/0x50
>  sock_ioctl+0x47/0x290
>  do_vfs_ioctl+0x7f/0x340
>  sys_ioctl+0x80/0xa0
>  system_call_fastpath+0x16/0x1b
> 
> i.e. outside of code paths run when the device is not yet enabled or
> already disabled. In particular, putting the device into D3hot is a
> pretty bad idea when it was already brought up.
> 
> Furthermore, all prior callers of the function made sure they're
> actually dealing with a PCI device, while the newly added one didn't.
> 
> In the same spirit, the .get_wol handler shouldn't indicate support
> for WOL for non-PCI devices.
> 
> Signed-off-by: Jan Beulich <jbeulich@novell.com>

Applied, thanks.
