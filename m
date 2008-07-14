From: Vivek Dasmohapatra <vivek@etla.org>
Subject: 2.6.24 ipw2200 driver can't be reset after firmware explodes
Date: Mon, 14 Jul 2008 13:27:51 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0807141240020.6889@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from batfish.pepperfish.net ([87.237.62.180]:53666 "EHLO
	flounder.pepperfish.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753346AbYGNOGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 10:06:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi: I have a thinkpad t43p with an ipw2200 driven piece of hardware in it.

04:02.0 Network controller [0280]:
  Intel Corporation PRO/Wireless 2915ABG Network Connection [8086:4224] (rev 05)
         Kernel driver in use: ipw2200
         Kernel modules: ipw2200

>From time to time, the firmware flakes out, and I get messages like this:
[ I'm not sure which version of the firmware I have, I can't see anything
   obvious in dmesg when the ipw2200 module loads: I have files like
   ipw-2.4-bss.fw in /lib/firmware if that helps ]

Jul 14 03:42:25 neko kernel: 
ipw2200: Failed to send SCAN_ABORT: Command timed out.
Jul 14 03:42:26 neko kernel: 
ipw2200: Failed to send CARD_DISABLE: Command timed out.
Jul 14 03:42:32 neko kernel: 
ipw2200: Failed to send SCAN_ABORT: Command timed out.
Jul 14 03:42:33 neko kernel: 
ipw2200: Failed to send CARD_DISABLE: Command timed out.
Jul 14 03:42:39 neko kernel: 
ipw2200: Failed to send SCAN_ABORT: Command timed out.

repeated again and again.

There's usually a "firmware error detected, restarting" message buried
somewhere in the logs before that happens.

Under kernel 2.6.16, I was able to fix this as follows:

echo -n 3 > /sys/class/net/$IFACE/device/power/state
sleep 1
echo -n 0 > /sys/class/net/$IFACE/device/power/state

( removing and reloading the module has no effect here, under
   either kernel 2.6.16 or 2.6.24: taking the interface down and
   bringing it up again is likewise ineffective )

However, I note that under 2.6.24 said /sys interface is no
longer present, so once the firmware dies, I am forced to either
hunt down a network cable with something useful on the other end,
or live without networking, or reboot.

Is there a new way to achieve the same effect in 2.6.24? If there's not,
is there likely to be in the future? Or should I just revert to 2.6.16
until such time as I replace my laptop and (hopefully) don't have to
struggle with the intel wifi hardware any more?

The firmware bug is covered here: 
http://www.intellinuxwireless.org/bugzilla/show_bug.cgi?id=875
if that's helpful/relevant.

[ CCd to netdev as I was told it would be of interest there too,
   apologies if this is not the case ]

-- 
Vivek
