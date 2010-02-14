From: Thomas Backlund <tmb@mandriva.org>
Subject: linux-2..6.33-rc7 and b43
Date: Sun, 14 Feb 2010 11:53:29 +0200
Message-ID: <4B77C819.9050602@mandriva.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mbox1.netikka.net ([213.250.81.202]:44413 "EHLO
	mbox1.netikka.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097Ab0BNJxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 04:53:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
(please cc me on replies)

We have a user that tried out b43, but got this in the logs:

--- cut ---
65858:Feb  9 22:05:16 elmo kernel: b43-phy2 ERROR: This device does not
support DMA on your system. Please use PIO instead. 65859:Feb  9 
22:05:16 elmo kernel: b43-phy2 ERROR: CONFIG_B43_FORCE_PIO must
be set in your kernel configuration.
65860:Feb  9 22:05:16 elmo kernel: b43-phy2 debug: Adding Interface type 2
65861:Feb  9 22:05:16 elmo kernel: b43-phy2 ERROR: Fatal DMA error:
0x00000400, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000 
 

65862:Feb  9 22:05:16 elmo kernel: b43-phy2 ERROR: This device does not
support DMA on your system. Please use PIO instead.
65863:Feb  9 22:05:16 elmo kernel: b43-phy2 ERROR: CONFIG_B43_FORCE_PIO 
must be set in your kernel configuration.
--- cut ---



But reading the Kconfig help, it states:
--- cut ---
config B43_FORCE_PIO
         bool "Force usage of PIO instead of DMA"
         depends on B43 && B43_DEBUG
         ---help---
           This will disable DMA and always enable PIO instead.

           Say N!
           This is only for debugging the PIO engine code. You do
           _NOT_ want to enable this.
--- cut ---


So,
wich one is it ?

Do I belive the dmesg output, or the Kconfig ?

Note,
the b43 works for the user if he enable the CONFIG_B43_FORCE_PIO.

But I'm thinking of this problem from a distro point of view.
Will it break for others if I enable it ?

--
Thomas
