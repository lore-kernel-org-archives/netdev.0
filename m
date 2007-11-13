From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Subject: possible bug in tcp_probe
Date: Tue, 13 Nov 2007 11:26:15 +0000
Message-ID: <20071113112615.GA7491@nuim.ie>
Reply-To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:59512 "EHLO mango.nuim.ie"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751834AbXKMM0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 07:26:09 -0500
Content-disposition: inline
Received: from boing.hamilton.local ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTP id <0JRF00NN5ZRI2T70@mango.nuim.ie> for
 netdev@vger.kernel.org; Tue, 13 Nov 2007 11:26:06 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm using linux v2.6.22.6 and tcp_probe with a couple of small
modifications[1]. 

Even with moderately large numbers of flows (16 on the one machine) and
increasingly as I monitor more flows than that, I get strange overflow
problems such as this one:

74.259589763 192.168.2.1 36988 192.168.3.5 5001 0x679c23dc 0x679bc3b4 18 13 9114624 78 76 10000 0 64
74.260590660 192.168.2.1 44261 192.168.3.5 5006 0x573bb3ed 0x573b700d 13 9 5254144 155 127 10000 0 64
74.261607478 192.168.2.1 44261 192.168.3.5 5006 0x588.066586741 192.168.2.1 33739 192.168.3.5 5009 0xe26d1767 0xe26cf577 2 3 13090816 443 15818 10000 0 64
88.066690797 192.168.2.1 33739 192.168.3.5 5009 0xe26d1767 0xe26cfb1f 3 3 13092864 2365 15818 10000 0 64
88.067625714 192.168.2.1 59385 192.168.3.5 5012 0x411c1090 0x411bd258 12 9 14578688 2807 15812 10000 0 64

As you can see the third line has been truncated as well as the next
roughly 14 seconds of data after which data continues writing as usual.

I don't think my small changes are causing this but perhaps I'm wrong.
Does anyone know what might be causing the above?

Many thanks for any ideas,
Gavin

[1] I have slightly modified tcp_probe to print out information for a range
of ports (instead of one port or all) and to print info from the congestion
avoidance inet_csk_ca struct.  This adds a couple of extra fields to the
end.  If either of these are of interest as patches I'll happily submit
them.

