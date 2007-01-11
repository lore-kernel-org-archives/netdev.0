From: Michael Buesch <mb@bu3sch.de>
Subject: What is in bcm43xx-wireless-dev.git?
Date: Thu, 11 Jan 2007 21:10:04 +0100
Message-ID: <200701112110.04311.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Linville, John" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:46429
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbXAKUOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jan 2007 15:14:00 -0500
To: bcm43xx-dev@lists.berlios.de
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case you wonder what's the future of bcm43xx, here's
a list of changes in my bcm43xx development tree:

      bcm43xx-d80211: Add some PHY register definitions.
      bcm43xx-d80211: Move ILT stuff to OFDM table stuff
      bcm43xx-d80211: Remove PHY OFDM routing bit, if we are on A-PHY.
      bcm43xx-d80211: Merge new LO-control code.
      bcm43xx-d80211: Fix compilation: Missing files for LO and VSTACK.
      bcm43xx-d80211: Rename struct bcm43xx_phyinfo to struct bcm43xx_phy
      bcm43xx-d80211: merge struct bcm43xx_radioinfo into struct bcm43xx_phy
      bcm43xx-d80211: Merge all "radio" stuff into phy.c
      bcm43xx-d80211: Fix antenna selection for TX and RX.
      bcm43xx-d80211: Fix bogus LO validation failure.
      bcm43xx-d80211: Remove netpoll and ethtool stuff.
      Remove obsolete SSB driver library.
      Implement new SSB subsystem.
      bcm43xx-d80211: Port driver to the new SSB subsystem.

Well, that doesn't tell you anything, right?
Let's explain it:

Most significant changes are the new "LO" code and
the completely rewritten "SSB" subsystem.

The LO calibration code is not yet finished and contains
a few bugs, so it works _worse_ that the LO calibration
code that's in mainline kernel. But it's the first step
in the direction to support hwpctl cards (4318).

The other major change is the new SSB subsystem. This is
a big step in the embedded direction. The new SSB subsystem
makes it possible to run an (almost) vanilla (vanilla, as in
my tree, which is supposed to get merged upstream some time :))
kernel on broadcom MIPS based embedded WLAN routers (openWRT).

bcm43xx works on the new subsystem. A working b44 port is
available, but not included here. We might probably want to
merge that through jeff directly once this is upstream.
The SSB subsystem is able to boot my Linksys WRT54G.
Wireless and LAN with SSB based chips basically works.

So, what to do?
Next think will be to fix the LO code to make it ready
for upstream merge. I don't know if that means "making
4318 usable", too. Hopefully it does. Let's see. ;)

If you want to test this, get it from my repository.
If you have a linville-wireless-dev tree around, please
_don't_ clone my tree, but simply pull my stuff into
a seperate branch of that tree:

git branch crazy_stuff
git checkout crazy_stuff
git pull http://bu3sch.de/git/wireless-dev.git master

That will save lots of bandwidth. (Yours and mine) Thanks! ;)

Here's also a bzipped patch between today's linville-wireless-dev
and my tree. Yeah, it's huge, so not attached. :)

http://bu3sch.de/misc/linville_to_buesch_20070111.patch.bz2

-- 
Greetings Michael.
