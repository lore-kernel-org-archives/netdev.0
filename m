From: Michael Tokarev <mjt@tls.msk.ru>
Subject: source IP address for ARP requests
Date: Tue, 07 May 2013 19:30:21 +0400
Message-ID: <51891E0D.7050907@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:38823 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753544Ab3EGPaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 May 2013 11:30:23 -0400
Received: from tsrv.corpit.ru (tsrv.tls.msk.ru [192.168.177.2])
	by isrv.corpit.ru (Postfix) with ESMTP id DCF6B404AB
	for <netdev@vger.kernel.org>; Tue,  7 May 2013 19:30:21 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

With a somewhat unusual configuration:

 eth0  10.0.0.1/32
 eth1  192.168.1.1/24
 route add 10.0.0.2 dev eth1 src 10.0.0.1

namely, so that just one ip address is available
on an "unrelated" subnet, with "our" address taken
from another interface.

With this config, ARPs for 10.0.0.2 are sent to eth1
with source address of 192.168.1.1, even if "src"
is configured for the route in question:

 9:28:46.220680 ARP, Request who-has 10.0.0.2 tell 192.168.1.1, length 28

Is that right, or should the host send ARP requests
with src=10.0.0.1?

This is kernel 3.2(.40).

Thank you!

/mjt
