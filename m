From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v3 5/5] r8169: support RTL8411
Date: Mon, 9 Apr 2012 20:02:29 +0200
Message-ID: <20120409180229.GA28837@electric-eye.fr.zoreil.com>
References: <1333089184-1773-5-git-send-email-hayeswang@realtek.com> <1333090086-1815-1-git-send-email-hayeswang@realtek.com> <20120330072521.GA11548@electric-eye.fr.zoreil.com> <52E71C7B42A44FB1A8556BB6B75CD9A0@realtek.com.tw> <20120405083743.GB32027@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47593 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756808Ab2DISGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2012 14:06:20 -0400
Content-Disposition: inline
In-Reply-To: <20120405083743.GB32027@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
> hayeswang <hayeswang@realtek.com> :
> [...]
> > There is nothing to do for rtl_init_jumbo_ops. It is all right for keeping
> > NULL.
> 
> Ok, I'll add it to the commit message for future reference.
> 
> > Do I need to resend this patch?
> 
> No, I'll give it a short testing and forward to David.

Rx/Tx is ok, WoL + shutdown is ok but runtime power management is not.

I tried net-next + your patches + cff4c16296754888b6fd8c886bc860a888e20257
("r8169: enable napi on resume.", required for RPM or suspend/resume after
regression in da78dbff2e05630921c551dbbc70a4b7981a8fff).

- set a 8402 and a 8411 in the same test box
- ip addr add ... 
- ip link set dev ... up 
- start ping from remote host
- echo auto > /sys/bus/pci/devices/.../power/control
- unplug cable
  - ping stops flowing
  - cat /sys/bus/pci/devices/.../power/runtime_status
    -> "active"
- plug cable
  -> RPM status does not change, no link, no packet, no fun.

I have tried the same with a built-in 8168b (XID 18000000).
-> RPM status changes, link recovers, packets flow.

The 8168b is a bit special, so I swapped the 8411 for a 8102e (XID 04a00000).
It resumed correctly as well.

Any idea ?

-- 
Ueimor

Will code drivers for food.
