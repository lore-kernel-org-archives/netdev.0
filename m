From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Bug#656331: RTL8168b/8111b with ASUS M2A-VM (SB600): Network device stays down after resume
Date: Sun, 5 Feb 2012 18:57:30 +0100
Message-ID: <20120205175730.GA23604@electric-eye.fr.zoreil.com>
References: <1326896138.29125.86.camel@mattotaupa> <1326899011.3271.3.camel@deadeye> <1326900763.29125.117.camel@mattotaupa> <1326901834.3271.8.camel@deadeye> <1328383563.20142.23.camel@mattotaupa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, 656331@bugs.debian.org,
	netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Paul Menzel <pm.debian@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42136 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228Ab2BESJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 13:09:12 -0500
Content-Disposition: inline
In-Reply-To: <1328383563.20142.23.camel@mattotaupa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Menzel <pm.debian@googlemail.com> :
[http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=656331]
> I experienced this problem (only) three times until now. If I remember
> correctly the last time with 3.2.1. I still do not know how to reproduce
> this.

(good PR, nice)

An 'ethtool -d' and a 'mii-tool -v' of the device after a successful resume
and a failed one could help if it's a driver thing.

You may check if runtime power management is enabled or not, especially
after a failed resume. See the /sys/devices/pci....:../....:..:..../power
directory and its control, runtime_enabled and runtime_status files
(control = on -> runtime PM disabled, see Documentation/power/runtime_pm.txt)
If it is enabled and the link does not come up fast enough (5 s), runtime
PM will suspend the device. It should not matter as long as the link is
still present because the device should (TM) soon generate a power management
event. The latter not happening or the PME being ignored could explain
the bug. If so, temporarily disabling runtime PM for your device after a
failed resume instead of removing the module or the cable may be enough
to recover the link. It's just a guess though.

Please stay with v3.2 or above in the meantime.

-- 
Ueimor
