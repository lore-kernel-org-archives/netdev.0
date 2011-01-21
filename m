From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [regression] 2.6.37+ commit 0363466866d9.... breaks tcp ipv6
Date: Fri, 21 Jan 2011 14:15:49 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1101211414030.5816@JBRANDEB-DESK2.amr.corp.intel.com>
References: <4D335417.80704@xmsnet.nl> <4D35EF64.1040906@xmsnet.nl>  <AANLkTinejKw0pY5HncB2e0ocjqYuCwTBUwd2xkroWu+E@mail.gmail.com>  <4D36092B.1090406@xmsnet.nl> <1295388238.8449.10.camel@edumazet-laptop>  <4D39E2EC.9020906@xmsnet.nl> <1295639745.2609.29.camel@edumazet-laptop>
 <4D39EEDA.90902@xmsnet.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>
To: Hans de Bruin <jmdebruin@xmsnet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15848 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753898Ab1AUWPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 17:15:50 -0500
In-Reply-To: <4D39EEDA.90902@xmsnet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 21 Jan 2011, Hans de Bruin wrote:
> > tcpdump gets a copy of outgoing frames before NIC performs tx checksum
> > (if tx checksum handled by NIC), so it's normal to have "bad checksums"
> > on TX, unless you disable tx offloading (ethtool -K eth0 tx off)
> 
> That seem reasonable but: the bug was triggered because my nic could not 
> offload checksumming, so what's tx=on if there's no support for it? I 
> have turned tx off and my tcpdump still shows bad checksums on outgoing 
> tcp/ip6 packets. I have tried 2.6.36: bad checksums, 2.6.35 and 
> surprise: good checksums with tx=on.

maybe you're still seeing confusing output on tx due to GSO, try turning 
that off with ethtool -K ethX gso off

GSO still software-segments packets, and maybe the tap for tcpdump is 
before GSO operation.

> > I was referring to check with tcpdump incoming frames, because invalid
> > checksums in RX is sign that other peer sent wrong checksums
> 
> Ok, thats clear, the receiving site is apparently a more reliable 
> checksummer than the sending site.
> 
> 
