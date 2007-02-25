From: "Petri T. Koistinen" <petri.koistinen@iki.fi>
Subject: D-Link DGE-528T (r8159) autonegotation of 1000 Mbps link does not
 work
Date: Sun, 25 Feb 2007 15:56:30 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0702242214120.1830@qfy-uxvtj8-sro4so00-137.qupc.varg.sv>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ShuChen <shuchen@realtek.com.tw>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn2.hy.skanova.net ([81.228.8.111]:36473 "EHLO
	pne-smtpout3-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932855AbXBZH1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 02:27:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I just brought two D-Link DGE-528T (uses r8159 driver) network adapters
to have nice 1 Gbps home network between two computers.

I have gigabit crossover cable that is connected like this

Pin  Connector #1  Connector #2
1    white/orange  white/green
2    orange        green
3    white/green   white/orange
4    blue          white/brown
5    white/blue    brown
6    green         orange
7    white/brown   blue
8    brown         white/blue
(from: http://logout.sh/computers/net/gigabit/)

and when I use this cable I only get 10 Mbps connection when connected
another D-Link DGE-528T.

However if I connect other end of cable to Intel EtherExpress 100 Mbps
card, I get 100 Mbps connection auto-negotiated OK.

I can however force gigabit link on both D-Link DGE-528T using

	insmod ./r8169.ko media=0x10

command. And I get about 15 MiB/s transfer speed when testing
with netcat and pmr[1] (without NAPI). Which I count as some kind of
sucky gigabit connection.

Few questions for you:

Do anyone know if there some known bug in auto-negotiation with
Realtek 8159 chip? (Or is that just wrong cable?)

Can I force 1000 Mbps link on some other way than giving option to
insmod? Using /proc or something?

What kind of transfer speed you have reached with these cards? That
15 MiB/s is not what I expected.

Thanks!

Best regards,
Petri Koistinen

[1]
Test setup:
Server: nc -l -p 2000 </dev/zero
Client: nc 192.168.1.1 2000 | pmr >/dev/null

pmr (ex. pipemeter) is a command line filter that measures
bandwidth going through the pipe:
http://zakalwe.fi/~shd/foss/pmr/pmr-0.12.tar.bz2

