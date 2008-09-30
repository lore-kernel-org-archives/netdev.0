From: Bernhard Schmidt <berni@birkenwald.de>
Subject: tg3 + HP iLO2 -> IPv6 broken
Date: Tue, 30 Sep 2008 20:09:02 +0000 (UTC)
Message-ID: <gbu10u$uvr$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:45307 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753125AbYI3UKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 16:10:06 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1KklXn-0008Ks-6e
	for netdev@vger.kernel.org; Tue, 30 Sep 2008 20:10:03 +0000
Received: from ppp-88-217-17-205.dynamic.mnet-online.de ([88.217.17.205])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 20:10:03 +0000
Received: from berni by ppp-88-217-17-205.dynamic.mnet-online.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 20:10:03 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have an interesting bug here which I just can't put my finger on. 

I have just bought a HP Proliant DL320 G5p. It features an integrated
out-of-band controller called iLO2, which shares a physical ethernet
connection with one of the two BCM5715 GigE ports of the system. 

Basic problem:
I cannot get native IPv6 to work on the first (shared) GigE port.
The system does not autoconfigure an address and does not respond to
incoming neighbor solicitations for it's link-local address. Unless I
either

a) reboot the iLO2 by e.g. adjusting anything in the network settings
   (just switching the "use WINS servers from DHCP reply" is enough to
   restart it). This fixes my issues up until the next reboot of Linux,
   which breaks things again

_OR_

b) set the port to promiscous mode and leave it set.

The second GigE port using the same network chip does not have this
problem. 

Now I think this points to an issue with the iLO2, and indeed HP has
recently announced version 1.60 of the iLO2 firmware which is supposed
to fix an issue with dualstacked IPv4/IPv6 operation of the host, but
this version is installed. And IMHO, if the iLO2 would be the (sole)
culprit setting promisc mode should not help, should it?

Problem exists with both 2.6.26-1-amd64 from Debian lenny and vanilla
2.6.27-rc8 from kernel.org (same config). 

Does anyone have enough insight into how this ethernet port and the iLO
are connected which could help blaming either the driver or the iLO (or
both)?  I'll try to kick HP as well but since I don't have a support
contract for this (private) system other than the hardware warranty it
might take a while.

.config and dmesg available on request, I don't think they are helpful
here.

Regards,
Bernhard


