From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Tue, 1 May 2012 22:04:03 +0200
Message-ID: <20120501200403.GA20763@electric-eye.fr.zoreil.com>
References: <20120501182405.3dda59b9@stein> <20120501172748.GA17117@electric-eye.fr.zoreil.com> <20120501200423.6804dcf0@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42657 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751868Ab2EAUJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 16:09:51 -0400
Content-Disposition: inline
In-Reply-To: <20120501200423.6804dcf0@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Richter <stefanr@s5r6.in-berlin.de> :
[...]
> # dmesg | grep XID
> r8169 0000:0b:00.0: eth0: RTL8168c/8111c at 0xffffc9000005e000,
> 00:23:54:91:8a:2b, XID 1c4000c0 IRQ 49

I have no idea what has gone wrong with this chipset during the
3.3 to 3.4-rc5 move.

Can you apply the patch below on top of current ethtool
(git://git.kernel.org/pub/scm/network/ethtool/ethtool.git) and see
if it is enough to compare the register dumps (ethtool -d eth0).

diff --git a/realtek.c b/realtek.c
index c3d7ae5..ac83829 100644
--- a/realtek.c
+++ b/realtek.c
@@ -33,6 +33,7 @@ enum chip_type {
 	RTL8101Ebc,
 	RTL8100E1,
 	RTL8100E2,
+	RTL8168c0,
 };
 
 enum {
@@ -65,6 +66,7 @@ static struct chip_info {
 	{ "RTL-8101Ebc",	HW_REVID(0, 0, 1, 1, 0, 1, 0, 0) },
 	{ "RTL-8100E(1)",	HW_REVID(0, 0, 1, 1, 0, 0, 1, 0) },
 	{ "RTL-8100E(2)",	HW_REVID(0, 0, 1, 1, 1, 0, 1, 0) },
+	{ "RTL-8168c",		HW_REVID(0, 0, 1, 1, 1, 1, 0, 1) },
 	{ }
 };
 

> 
> # ethtool eth0
> Settings for eth0:
[...]
>                                drv probe ifdown ifup
>         Link detected: yes

Everything seems normal and we should be able to see both link up and down
messages.

> # ethtool -i eth0
[...]

Ok. This is a firmware free chipset anyway. Nothing strange in the interface
stats (ethtool -S eth0) ?

You may have to narrow things. Can you check if the r8169.c at
036dafa28da1e2565a8529de2ae663c37b7a0060 behaves the same ?

-- 
Ueimor
