From: Paul Hampson <Paul.Hampson@Pobox.com>
Subject: bcm43xx-d80211 broadcast reception with WPA
Date: Fri, 10 Nov 2006 09:23:46 +1100
Message-ID: <ej09qf$2nv$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:59803 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1424279AbWKJFFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 00:05:06 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GiOZa-0000oH-8x
	for netdev@vger.kernel.org; Fri, 10 Nov 2006 06:05:02 +0100
Received: from hydrogen.aie.net.au ([210.11.234.1])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 10 Nov 2006 06:05:02 +0100
Received: from Paul.Hampson by hydrogen.aie.net.au with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 10 Nov 2006 06:05:02 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Long time lurker, first time poster. ^_^

I've been backporting the bcm43xx-d80211 driver to whatever the released
2.6 kernel was using the rt2x00 project's d80211 stack (equivalent to
current wireless-dev but with a workaround for not having a ieee80211_dev
pointer and still using the _tfm interface instead of the _cypher interface.)

As of last night's wireless-dev tree bcm43xx, everything seems to be
operating fine except incoming broadcast traffic is coming in 14 bytes too
long and scrambled. I presume this means it's not decrypting properly...

Anyway, I just thought I'd mention it. It might have gone unnoticed by the
bcm43xx-d80211 developers, since it doesn't interfere with normal operation
(A DHCP client's only broadcasts are outgoing) and only showed up for me
because radvd's RAs were not arriving and my IPv6 address was not being set.

I couldn't find any mention of such a thing on the list, and I'm happy to
provide whatever debugging output is useful, but the laptop with the device
isn't with me at the moment.

Relevant facts:

Platform: Debian/unstable (PPC) w/linux-image-2.6.18-1-powerpc (2.6.18-3)
Drivers:  bcm43xx-d80211 from wireless-dev 774f233b7915a2c36480eb4d98e6f57938f04b7b
Firmware: 4.80.46.0 (BE, from AppleAirPortBrcm4311)
Stack:    ieee80211 from http://rt2x00.serialmonkey.com/rt2x00-cvs-daily.tar.gz
 2006110303 is the date on the output, I believe. Hasn't been updated since 20061028
 Plus a backport of the following commits:
[PATCH] d80211: extend extra_hdr_room to be a bytecount 522e078b9f1f8309770dd161d90ddac1573a7877
[PATCH] d80211: remove unused variable in ieee80211_rx_irqsafe 10bfc9cdf9621385a3b69aa35f9fa86cc6a46bc6
[PATCH] d80211: Add wireless statistics 448bf25bc9e3d70a211fdf235426472089371c43
(as well as anything else that showed up in a diff of the d80211 dir against the rt2x00
iee80211 dir and wasn't a 2.6.19ism or wireless-devism)

I'm basically using the instructions I posted at [1] except also patching rt2x00's
ieee80211 stack.

I acknowledge that any of the firmware version, the backporting, the forward porting
or the current lunar cycle may be causing this problem. If no one pipes up with an
insight, I'll try tonight with a v3 firmware, although the reason I moved to a v3
firmware was my previous build of bcm43xx-d80211 also wasn't getting an IPv6 address,
although I don't believe the RAs were scrambled in that case.

[1] http://openfacts.berlios.de/index-en.phtml?title=Broadcom_43xx_Linux_Driver/Debian_Unstable_with_Devicescape_802.11_stack

-- 
Paul "TBBle" Hampson
Opinions expressed here do not reflect the views of my employer
Hell, we don't even agree on my pay cheque

