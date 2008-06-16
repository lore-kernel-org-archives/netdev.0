From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 16 Jun 2008 21:13:54 +0200
Message-ID: <20080616191354.GA11760@orion.carnet.hr>
References: <20080616140454.GD5350@solarflare.com> <1551EAE59135BE47B544934E30FC4FC002AABD77@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	mirrors@debian.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:60375 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752778AbYFPTOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 15:14:02 -0400
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AABD77@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2008 at 08:52:13AM -0700, Michael Chan wrote:
> Josip, please provide more information such as driver version from
> ethtool -i, lspci, which version did you first see the problem, and
> whether the latest in 2.6.25 has the same problem.  Thanks.

The version with the problem is 2.6.22.18. The machine is fairly new
(HP DL360 G5), it only ever ran the .22 kernel. It was running this kernel
just fine for 112 days prior to the first incident on 2008-06-03, and since
then, the crash happened a total of 17 times. Our big rsync runs happen
twice a day, so it's a pretty bad record.

I can't verify that the crash was caused by the same thing every time
because I don't have console logs, but the symptoms are always the same - a
few minutes into the rsync run, it goes down, logging nothing in syslog.

I'll be rebooting into 2.6.25.6 shortly, and then I'll have information
relevant to that in about a day or two.

% sudo ethtool -i eth0
driver: bnx2
version: 1.5.11
firmware-version: 1.9.6
bus-info: 0000:03:00.0
% lspci
00:00.0 Host bridge: Intel Corporation 5000P Chipset Memory Controller Hub (rev b1)
00:02.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x4 Port 2 (rev b1)
00:03.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x4 Port 3 (rev b1)
00:04.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x8 Port 4-5 (rev b1)
00:05.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x4 Port 5 (rev b1)
00:06.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x4 Port 6 (rev b1)
00:07.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x4 Port 7 (rev b1)
00:10.0 Host bridge: Intel Corporation 5000 Series Chipset Error Reporting Registers (rev b1)
00:10.1 Host bridge: Intel Corporation 5000 Series Chipset Error Reporting Registers (rev b1)
00:10.2 Host bridge: Intel Corporation 5000 Series Chipset Error Reporting Registers (rev b1)
00:11.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved Registers (rev b1)
00:13.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved Registers (rev b1)
00:15.0 Host bridge: Intel Corporation 5000 Series Chipset FBD Registers (rev b1)
00:16.0 Host bridge: Intel Corporation 5000 Series Chipset FBD Registers (rev b1)
00:1d.0 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #1 (rev 09)
00:1d.1 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #2 (rev 09)
00:1d.2 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #3 (rev 09)
00:1d.3 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #4 (rev 09)
00:1d.7 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset EHCI USB2 Controller (rev 09)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev d9)
00:1f.0 ISA bridge: Intel Corporation 631xESB/632xESB/3100 Chipset LPC Interface Controller (rev 09)
00:1f.1 IDE interface: Intel Corporation 631xESB/632xESB IDE Controller (rev 09)
01:03.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02)
01:04.0 System peripheral: Compaq Computer Corporation Integrated Lights Out Controller (rev 03)
01:04.2 System peripheral: Compaq Computer Corporation Integrated Lights Out  Processor (rev 03)
01:04.4 USB Controller: Hewlett-Packard Company Unknown device 3300
01:04.6 Serial bus controller [0c07]: Hewlett-Packard Company Unknown device 3302
02:00.0 PCI bridge: Broadcom EPB PCI-Express to PCI-X Bridge (rev c3)
03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)
04:00.0 PCI bridge: Broadcom EPB PCI-Express to PCI-X Bridge (rev c3)
05:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)
06:00.0 RAID bus controller: Hewlett-Packard Company Hewlett-Packard Smart Array Controller (rev 01)
09:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Upstream Port (rev 01)
09:00.3 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express to PCI-X Bridge (rev 01)
0a:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Downstream Port E1 (rev 01)
0a:01.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Downstream Port E2 (rev 01)
0a:02.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Downstream Port E3 (rev 01)

-- 
     2. That which causes joy or happiness.
