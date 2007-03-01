From: NetArt - Grzegorz Nosek <grzegorz.nosek@netart.pl>
Subject: Very slow routing table modification if RTA_FLOW is set
Date: Thu, 1 Mar 2007 15:29:11 +0100
Message-ID: <20070301142911.GA8187__9139.80771224505$1172826428$gmane$org@tech.serwery.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ajx114.rev.netart.pl ([85.128.128.114]:54401 "EHLO
	tech.serwery.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933142AbXCBJGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 04:06:53 -0500
Received: from gnosek by tech.serwery.pl with local (Exim 4.52)
	id 1HN2vv-0007C4-Vu
	for netdev@vger.kernel.org; Fri, 02 Mar 2007 09:16:07 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all,

I have noticed that using realm patch for quagga
<http://vcalinus.gemenii.ro/quaggarealms.html> causes the kernel to
spend a lot more time processing rtnetlink messages.

If routes added to the kernel are not tagged with a realm number, the
time from sending a netlink cmd to receiving an ack is mostly stable
at several dozen microseconds or less.

However, if I add route tagging with 'neighbor X.X.X.X realm
origin-as', the time spent in kernel:
1. seems to increase with the numer of FIB entries
2. is much more jittery

The net result is that after adding about 100k routes, the time between
cmd and ack is usually around 4 _milli_seconds, but sometimes the
route is added immediately (i.e. after 20 us or so), just like when
the table is nearly empty. Overall, the process of receiving a full
routing table slows down from a minute to about 11.

The kernel is 2.6.18.6. I have tried using both FIB_HASH and FIB_TRIE.
I'll try to collect dome results from oprofile next and if anything
pops out at me, I'll let you know.

The core of the quagga patch with regard to the kernel is:

  if (rib->realmto)
      addattr32 (&req.n, sizeof req, RTA_FLOW, rib->realmto);

while constructing the netlink packet.

Is this a known problem? Can anything be done about it?

Please CC as I'm not subscribed to the list.

Best regards,
 Grzegorz Nosek

