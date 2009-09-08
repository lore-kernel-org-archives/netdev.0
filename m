From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 00/14] pktgen update for net-next (2.6.32)
Date: Tue, 8 Sep 2009 14:21:12 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909081409210.20285@ask.diku.dk>
References: <20090827235506.624381734@vyatta.com> <19110.17776.721680.242313@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: robert@herjulf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:40760 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132AbZIHMVM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2009 08:21:12 -0400
In-Reply-To: <19110.17776.721680.242313@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 8 Sep 2009, robert@herjulf.net wrote:
> Stephen Hemminger writes:
> > The biggest change is switching to monotonic clock (ktime) and
> > high resolution timers for the interpacket delay.
>
> Opteron Barcelona 2.3 GHz with net-next 2.6.31-rc5bifrost-x86_64.
>
> Sending different pkt-sizes at maxrate using one CPU-core (of eight)
> with ixgbe driver and Intel's 82598 chip.
>
>      w. patch
> 64    4761904    3846153
> 128   4545454    3703703
> 256   4545454    3703703
> 512   2380952    2380952
> 1024  1204819    1204819
> 1500   826446     826446
>
> We increase max sending rate from 3.8 Mpps to 4.8 Mpps for 64 byte pkts

I can also measure a performance improvement.

Generator machine, AMD Phenom 9950 quad core, using a 10GbE Intel 82599 
NIC (6 port 10GbE from Hotlava Systems Inc.).

With patches:
-------------
tx_pkt_sz: 64  TX-pps: 9426724
tx_pkt_sz: 128 TX-pps: 8220396
tx_pkt_sz: 256 TX-pps: 4463415
tx_pkt_sz: 384 TX-pps: 3063025
tx_pkt_sz: 512 TX-pps: 2331636
tx_pkt_sz: 640 TX-pps: 1879640
tx_pkt_sz: 768 TX-pps: 1577957
tx_pkt_sz: 896 TX-pps: 1359122
tx_pkt_sz: 1024 TX-pps: 1193118
tx_pkt_sz: 1152 TX-pps: 1062726
tx_pkt_sz: 1280 TX-pps: 958408
tx_pkt_sz: 1408 TX-pps: 873167
tx_pkt_sz: 1514 TX-pps: 812591

Without patches:
----------------
tx_pkt_sz: 64  TX-pps: 8372361
tx_pkt_sz: 128 TX-pps: 7915717
tx_pkt_sz: 256 TX-pps: 4462400
tx_pkt_sz: 384 TX-pps: 3059712
tx_pkt_sz: 512 TX-pps: 2332164
tx_pkt_sz: 640 TX-pps: 1882343
tx_pkt_sz: 768 TX-pps: 1577543
tx_pkt_sz: 896 TX-pps: 1358061
tx_pkt_sz: 1024 TX-pps: 1192788
tx_pkt_sz: 1152 TX-pps: 1062959
tx_pkt_sz: 1280 TX-pps: 958622
tx_pkt_sz: 1408 TX-pps: 872934
tx_pkt_sz: 1514 TX-pps: 812771

It really makes a difference for small packet sizes.

  64 bytes pkts: 8.4 Mpps to 9.4 Mpps.
128 bytes pkts: 7.9 Mpps to 8.2 Mpps

Notice that the numbers for pkt sizes above 128 bytes are really close to 
wirespeed 10GbE rates, when taking ethernet framing into account.

> Thanks a lot Stephen.

Yes, thanks a lot Stephen! :-)

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
