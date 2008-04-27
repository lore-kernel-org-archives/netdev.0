From: Jeremy Jackson <jerj@coplanar.net>
Subject: adding tcpdump/OAM support to usb ATM devices
Date: Sun, 27 Apr 2008 17:31:53 -0400
Message-ID: <1209331913.8768.214.camel@ragnarok>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.coplanar.net ([70.47.139.2]:47422 "EHLO
	titan.coplanar.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbYD0Vbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 17:31:51 -0400
Received: from [70.47.139.174] (ragnarok.coplanar.net [70.47.139.174] (may be forged))
	(authenticated bits=0)
	by titan.coplanar.net (8.14.1/8.14.1/Debian-8ubuntu1) with ESMTP id m3RLVmfs016846
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 27 Apr 2008 17:31:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

who cares about ATM?  Well anyone using ADSL/2/2+ high speed internet
access is stuck with it, and that's not a small number of people.

Diagnosing problems is often complicated by the fact that large backhaul
networks appear as only 1 IP hop in traceroute.

The goal is to support sending and receiving F5 OAM cells on a Linux
host, from in-use PVCs bound to a br2684 bridge, your typical USB ADSL
modem.  The ATM OAM segment "ping" can be useful in troubleshooting, yet
few modems support it, and *none* return timing and other detailed
information.

The modems running embedded Linux internally (openwrt AR7 for example)
could also use this.

The question: what is the recommended way to push the captured cells to
userspace?  raw ATM socket, netlink, packet socket, i'm not up to speed
here people!

in 2.6.22 drivers/usb/atm/usbatm.c::usbatm_extract_one_cell()

cells received for open PVC/SVC sockets are processed, however OAM cells
are dropped, and cells to unbound VPI/VCI are dropped.

This seems the likely place to route cells somewhere useful, but what
mechanism to use?

-- 
Jeremy Jackson
Coplanar Networks
(519)489-4903
http://www.coplanar.net
jerj@coplanar.net

