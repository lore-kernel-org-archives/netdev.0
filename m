From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Poor IPv6 TCP performance in 4.3-rc3
Date: Wed, 30 Sep 2015 00:32:53 +0100
Message-ID: <20150929233253.GS21513@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:56275 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbbI2Xc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:32:59 -0400
Received: from n2100.arm.linux.org.uk ([fd8f:7570:feb6:1:214:fdff:fe10:4f86]:60290)
	by pandora.arm.linux.org.uk with esmtpsa (TLSv1:DHE-RSA-AES256-SHA:256)
	(Exim 4.82_1-5b7a7c0-XX)
	(envelope-from <linux@arm.linux.org.uk>)
	id 1Zh4OG-0006K8-Dk
	for netdev@vger.kernel.org; Wed, 30 Sep 2015 00:32:56 +0100
Received: from linux by n2100.arm.linux.org.uk with local (Exim 4.76)
	(envelope-from <linux@n2100.arm.linux.org.uk>)
	id 1Zh4OD-0007jw-Gd
	for netdev@vger.kernel.org; Wed, 30 Sep 2015 00:32:53 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm seeing really poor IPv6 performance compared to IPv4.  I've
checked using two different ARM platforms - an iMX6 platform using
the FEC driver, and an Armada 38x using mvneta.

The following was captured using iperf between the target system
and my laptop.  The problem only occurs one-way.  The 4.3-rc3
platform is running iperf in server mode, the laptop is in client
mode.

Armada 38x:
ipv6: [  4]  0.0-23.9 sec   170 KBytes  58.3 Kbits/sec
ipv4: [  4]  0.0-10.0 sec  1.09 GBytes   936 Mbits/sec

iMX6Q:
ipv6: [  4]  0.0-11.1 sec   640 KBytes   474 Kbits/sec
ipv4: [  4]  0.0-10.0 sec   655 MBytes   549 Mbits/sec

iMX6D with 4.2:
ipv6: [  4]  0.0-10.0 sec   685 MBytes   574 Mbits/sec
ipv4: [  4]  0.0-10.0 sec   696 MBytes   583 Mbits/sec

It looks like there's an IPv6 regression between 4.2 and 4.3-rc3.

Turning GRO off on Armada 38x gives:
ipv6: [  4]  0.0-10.0 sec  1.08 GBytes   923 Mbits/sec
ipv4: [  5]  0.0-10.0 sec  1.09 GBytes   936 Mbits/sec

I haven't started to debug yet, but I thought I'd post a heads-up in
case it's a known problem.  I'll try to get some packet logs on
Thursday, and I'll try to bisect.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
