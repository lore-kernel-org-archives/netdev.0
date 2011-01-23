From: "juice" <juice@swagman.org>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Sun, 23 Jan 2011 23:48:41 +0200
Message-ID: <8ad1defdf427ceb7af94fad4d216b006.squirrel@www.liukuma.net>
References: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com>
    <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>
    <alpine.WNT.2.00.1101211400000.5816@JBRANDEB-DESK2.amr.corp.intel.com>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Loke, Chetan" <chetan.loke@netscout.com>,
	"Jon Zhou" <jon.zhou@jdsu.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Stephen Hemming
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:43572 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752206Ab1AWVsu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jan 2011 16:48:50 -0500
In-Reply-To: <alpine.WNT.2.00.1101211400000.5816@JBRANDEB-DESK2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> your computation of Bandwidth (as Ben Greear said) is not accounting for
> the interframe gaps.  Maybe more useful is to note that wire speed 64 byte
> packets is 1.44 Million packets per second.

I am aware of the fact that interframe gap eats away some of the bandwidth
from actual data bytes, and I am taking that into consideration.
My benchmark here is the Spirent AX4000 network analyzer, which can send
and receive full utilization of GE line.

The measurement when sending full line rate from AX4000 are:
  Total bitrate:             761.903 MBits/s
  Packet rate:               1488090 packets/s
  Bandwidth:                 76.19% GE
  Average packet intereval:  0.67 us


> I think you need different hardware (again) as you have saddled yourself
> with a x1 PCIe connected adapter.  This adapter is not well suited to
> small packet traffic because the sheer amount of transactions is effected
> by the added latency due to the x1 connector (vs our dual port 1GbE
> adapters with a x4 connector)
>
> with Core i3/5/7 or newer cpus you should be able to saturate a 1Gb link
> with a single core/queue.  With Core2 era processors you may have some
> difficulty, with anything older than that you won't make it. :-)

The CPU I have on the machine driving the card is a dual-core Xeon:
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 26
model name	: Intel(R) Xeon(R) CPU           W3503  @ 2.40GHz
stepping	: 5
cpu MHz		: 2399.926
cache size	: 4096 KB

I do hope this is enough to go, as it is easier for me to get a better
network adapter than order a new faster machine as I jut got this one
last december :)


> My suggestion is to get one of the igb based adapters, 82576, or 82580
> based that run the igb driver.
>
> If you can't get a hold of those you should be able to easily get 1.1M pps
> from an 82571 adapter.

I will order the 82576 card and try my tests with that.


> you may also want to try reducing the tx descriptor ring count to 128
> using ethtool, and change the ethtool -C rx-usecs 20 setting, try
> 20,30,40,50,60

So this could up my current network card to a little faster?
If I can reach 1.1Mpackets/s, thats about 560Mbits/s. At least it would
get me a little closet to what I am trying to achieve.

Yours, Jussi Ohenoja




