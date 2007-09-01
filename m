From: Christian Kujau <lists@nerdbynature.de>
Subject: Oops in 2.6.23-rc5
Date: Sat, 1 Sep 2007 22:57:05 +0200 (CEST)
Message-ID: <alpine.DEB.0.999.0709012236460.6640@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.g-housing.de ([81.169.133.75]:38185 "EHLO mail.g-house.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933301AbXIBAJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Sep 2007 20:09:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

today I switched from 2.6.22.3 to 2.6.23-rc5 (skipped quite a few -rc 
versions due to lack of time), and the box keeps panicking under certain 
circumstances. I suspected disk related problems, because: when the box 
is up, I usually resume ~10 bittorrent files. When doing this, each
file (~200MB...1GB) is checked and disk activity is pretty high (20MB/s
or so), and after 1 minute of doing so the box panicks. Every time.

However, I could not reproduce it while generating disk-io with say tar 
or rsync to the same fs. It always panicked when the torrent client(s) 
start up. As the box would not log anything via remote-syslog before 
halting, I connected a vga display. As I don't have a digital camera, I 
tried to write down some stuff: http://ww.nerdbynature.de/bits/2.6.23-rc5/
(I'll try to write down the full oops to this place, or what was still 
visible from it, because the first few(?) lines where lost, display 
scrollback was not working, only sysrq was).

The backtrace mentions do_page_fault, error_code, tcp_rtt_estimator, 
tcp_ack_saw_timestamp, tcp_ack, tcp_rcv_established, tcp_v4_do_rcv, 
tcp_v4_rcv, ip_local_delimiter, netif_receive_skb, process_backlog, 
net_rcv_activate, __do_softirq, do_softirq - in that order. As said, the 
correct addresses will be put on above's url (Q: do I really need *all* 
the numbers? Or just a few?). These snippets made me suspect network 
related issues, because: aside from disk-io, the bittorrent clients will 
establish quite a few (~50 in total) connections to all the peers.

The box is a amd-k7, 2 NICs (forcedeth, 3c59x), 2 GB RAM, ACPI 
disabled, gcc-4.1

Thanks for looking into this,
Christian.
-- 
BOFH excuse #335:

the AA battery in the wallclock sends magnetic interference
