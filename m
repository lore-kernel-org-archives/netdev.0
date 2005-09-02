From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent 2.4.x/2.6.x kernels
Date: Sat, 3 Sep 2005 01:18:10 +0400
Message-ID: <20050902211810.GB18605@yakov.inr.ac.ru>
References: <Pine.LNX.4.61.0509011713240.6083@guppy.limebrokerage.com> <20050901.154300.118239765.davem@davemloft.net> <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com> <20050902183656.GA16537@yakov.inr.ac.ru> <Pine.LNX.4.61.0509021609430.6083@guppy.limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Ion Badulescu <lists@limebrokerage.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Ion Badulescu <ion.badulescu@limegroup.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0509021609430.6083@guppy.limebrokerage.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Well, take a look at the double acks for 84439343, 84440447 and 84441059, 
> they seem pretty much identical to me.

It is just a little tcpdump glitch.

19:34:54.532271 < 10.2.20.246.33060 > 65.171.224.182.8700: . 44:44(0) ack 84439343 win 24544 <nop,nop,timestamp 226080638 99717832> (DF) (ttl 64, id 60946)
19:34:54.532432 < 10.2.20.246.33060 > 65.171.224.182.8700: . 44:44(0) ack 84439343 win 24544 <nop,nop,timestamp 226080638 99717832> (DF) (ttl 64, id 60946)

It is one ACK (look at IP ID), shown twice. This happens sometimes
with our packet socket.


> >I still do not know how the value of 184 is possible in your case,
> >I would expect 730 as an absolute possible minumum. I see 9420 (2355*4).
> 
> The numbers I mentioned are straight from the tcpdump and are not scaled, 

I understood. I expect when 184*4, when you said 184. But minimum is
still 730 (unscaled 1460*2). If you really saw values lower than 730
(unscaled 1460*2), there is another more severe problem and the suggested
patch will not solve it.

Alexey
