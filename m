From: Phil Oester <kernel@linuxace.com>
Subject: Arp problems after upgrade to 3.6
Date: Tue, 27 Nov 2012 08:29:54 -0800
Message-ID: <20121127162954.GA18505@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63787 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861Ab2K0Q37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 11:29:59 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so9002153pbc.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 08:29:58 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upgraded a box to 3.6.7 yesterday, and started noticing it becoming
unreachable occasionally.  Watching arp traffic, it appears it is
sometimes arping for the gateway using the wrong source IP in the requests. 
Sample trace from bond1:

11:10:13.489388 ARP, Request who-has 10.253.128.13 tell 10.253.128.6, length 28
11:10:14.489372 ARP, Request who-has 10.253.128.13 tell 10.253.128.6, length 28
11:10:15.489358 ARP, Request who-has 10.253.128.13 tell 10.253.128.6, length 28
11:10:16.489517 ARP, Request who-has 10.253.128.13 tell 10.253.128.6, length 28
11:10:16.489518 ARP, Request who-has 10.253.128.13 tell 10.253.128.14, length 28
11:10:16.490025 ARP, Reply 10.253.128.13 is-at 00:d0:04:b1:d4:00, length 46
11:11:43.618851 ARP, Request who-has 10.253.128.13 tell 10.253.128.14, length 28
11:11:43.619406 ARP, Reply 10.253.128.13 is-at 00:d0:04:b1:d4:00, length 46
11:15:05.792656 ARP, Request who-has 10.253.128.13 tell 10.253.128.6, length 28
11:15:06.789369 ARP, Request who-has 10.253.128.13 tell 10.253.128.6, length 28
11:15:07.789338 ARP, Request who-has 10.253.128.13 tell 10.253.128.6, length 28
11:15:08.789939 ARP, Request who-has 10.253.128.13 tell 10.253.128.6, length 28 

Seems to be getting bond0 and bond1 IPs confused here:

12: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether xx:xx:xx:xx:xx:20 brd ff:ff:ff:ff:ff:ff
    inet 10.253.128.6/30 brd 10.253.128.7 scope global bond0
17: bond1: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether xx:xx:xx:xx:xx:22 brd ff:ff:ff:ff:ff:ff
    inet 10.253.128.14/30 brd 10.253.128.15 scope global bond1 

This box is still up, so if there is any additional information I can provide
before rebooting it, please let me know.

Phil Oester
