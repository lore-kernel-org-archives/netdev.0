From: Daniel Drake <dsd@gentoo.org>
Subject: sky2 drops immediately after boot
Date: Wed, 19 Jul 2006 10:03:42 +0100
Message-ID: <44BDF56E.6000202@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcclung@nebrwesleyan.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:25262 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932533AbWGSI4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 04:56:55 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Here's another sky2 issue for you to look at when you have some time. 
mcclung@nebrwesleyan.edu reported this at http://bugs.gentoo.org/136508 
but I have tried to include all relevant info here.

The connection seems to work very briefly during boot, so the user can 
get an IP over DHCP. After that point, the connection stops working.

The adapter is integrated into a MSI K8N nVidia 4 Platinum motherboard.
sky2 v1.5 addr 0xfe6fc000 irq 217 Yukon-EC (0xb6) rev 1
lspci: http://bugs.gentoo.org/attachment.cgi?id=92181&action=view

This has all been reproduced on 2.6.18-rc2 with the "sky2: NAPI poll 
fix" patch on top (sky2 v1.5).

sky2 v0.15 worked, and sk98lin works when he can get it to compile.

This is being used on a half duplex 10mbps connection -- I'm only 
guessing, but I wonder if this might have something to do with the failure.

Here is dmesg:
http://bugs.gentoo.org/attachment.cgi?id=92182&action=view
and /proc/interrupts
http://bugs.gentoo.org/attachment.cgi?id=92183&action=view

We also tried with the disable_msi parameter:
dmesg: http://bugs.gentoo.org/attachment.cgi?id=92184&action=view
interrupts: http://bugs.gentoo.org/attachment.cgi?id=92185&action=view

When the connection drops, the interrupt counter is still increasing as 
normal.

Any ideas? What extra info can we provide?

Thanks,
Daniel

