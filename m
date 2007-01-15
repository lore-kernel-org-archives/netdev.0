From: Jens Stroebel <drifter@bcsoft.de>
Subject: network failures w. r8169 (RTL8111/RTL8168B)
Date: Mon, 15 Jan 2007 15:38:57 +0100
Message-ID: <20070115143857.GA2666@lida5.home.bcs>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:58020 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbXAOOoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 09:44:16 -0500
Received: from lida5.home.bcs (unknown [192.168.142.55])
	by lunaslave.outerlounge.de (Postfix) with ESMTP id C58A22556E
	for <netdev@vger.kernel.org>; Mon, 15 Jan 2007 15:39:06 +0100 (CET)
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


				Hello.

I am trying to get a RTL8111 (RealTek ethernet controller) running w.
the r8169 kernel module. I am using kernel 2.6.19.2 on a
LinuxFromScratch system; the motherboard on which said RTL8111 sits is
an Asus P5B.

lspci says (regarding the ethernet chip):
03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 01)

During the use of network connections, we experience "network transfer
stops" during which a transfer seems to stall completely for many
seconds, after which the transfer runs as if nothing happened.

This is reproducable everytime w. 
 svn co http://svnserver/svn/tree
   (hangs VERY LONG)

and w. LWP::Parallel::UserAgent. With the latter, I fired 100 runs of
100 requests, 7 "clients" trying parallel requests.
Of these 100 runs, at least one, sometimes 2 stall for about 90 secs,
after which the run continues and ends successfully, although the time
of more than 90 secs for 100 requests can't be called sucessful, really.

Both the subversion checkout and the performance testing via
LWP::Parallel::UserAgent run as expected (-> without stalling somewhere)
on our other machines which do not have RTL8111.
They also run as expected with kernels 2.6.18.x and
the realtek driver r1000.

With kernel 2.6.19.x, the r1000 driver is unusable as it has enormous
packet loss (used version: r1000_v1.05.tgz).
The r8169 SEEMS to have no packet loss (ping, ping -f) but above
mentioned phenomenon seems to indicate otherwise.

Has someone experienced similar effects w. r8169.ko and RTL8111?
(I searched the archives but didn't quite find anything like this)

I also tried kernel 2.6.20-rc5 to see if the problem eventually went
away, but unfortunately the scenario remains the same.

		Greets,
		  Jens
-- 
drifter@bcsoft.de
			23.....56.......drifting 
