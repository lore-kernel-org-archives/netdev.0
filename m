From: Michael Tokarev <mjt@tls.msk.ru>
Subject: e100 + VLANs?
Date: Sat, 08 Oct 2011 14:08:45 +0400
Message-ID: <4E90212D.8030009@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:38107 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575Ab1JHKIs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Oct 2011 06:08:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yesterday I tried to use 802.1Q VLAN tagging with an (oldish)
e100-driven network card, identified by lspci like this:

 00:12.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 Ethernet Pro 100 (rev 02)

Just to discover that it does not quite work: packets of
size 1497+ bytes gets lost.

This appears to be a classical problems in this case -
something forgot to allocate extra 4 bytes for the
packets.

There's at least one bugreport from 2008 (!) about this
very issue: http://bugs.centos.org/view.php?id=2719
which is still open.

The kernel I tried this on was 2.6.32, I checked git log
for drivers/net/e100.c - there was no changes up to
current version which may be related to this issue.

The question: is this a driver problem or hardware? If
it's the driver, can it be fixed? And if it's hardware,
can the driver notify the user somehow - like, by refusing
to enable VLAN (sub)devices maybe?

Yesterday it was actually a bit more complicated for me,
since the card in question was used to connect to our
ISP, and they use fixed MAC address per port, so I had
to find another NIC which is a) able to work with VLAN
tags properly, and b) is able to change its mac address.
Lucky I had a VIA RhineIII which does both :)

Thanks,

/mjt
