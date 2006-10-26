From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Announce] Netchannels ported to the latest git tree. Gigabit benchmark. Complete rout.
Date: Thu, 26 Oct 2006 19:23:50 +0400
Message-ID: <20061026152350.GB11062@2ka.mipt.ru>
References: <20061020095304.GA22445@2ka.mipt.ru> <20061026105151.GA8325@2ka.mipt.ru> <20061026134436.GA22407@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44433 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1423562AbWJZPYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 11:24:07 -0400
To: bert hubert <bert.hubert@netherlabs.nl>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061026134436.GA22407@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 26, 2006 at 03:44:37PM +0200, bert hubert (bert.hubert@netherlabs.nl) wrote:
> On Thu, Oct 26, 2006 at 02:51:51PM +0400, Evgeniy Polyakov wrote:
> 
> > Benchmark uses 128 bytes sending/receiving per syscall (no latency
> > checks, only throughput.
> > Receiving CPU usage is 3 times less (90% socket code vs. 30%
> > Sending CPU usage is 5 times less (upto 50% vs. upto 10%).
> 
> Wow. I currently lack the hardware to reproduce your measurements, do you
> have any idea of how these numbers would be with 1024 byte "system calls"?

Results are not that exciting in this case.
Receiving CPU usage is about the same: it steady grows upto about 30-35%
(netchannel stops growing after some time with about 28%, socket slowly
continues), but netchannel's speed is smaller.
It can be described by that fact, that unetstack uses C-coded
checksumming (the dumbies algo I think) and additional memory copy, 
which becomes visible in case of big buffers (it can be eliminated though, 
I will think about better interface).
The same applies to sending - CPU usage is smaller, but speed is smaller
too. (10% vs. 8% compared to 30 MB/sec vs. 24 MB/sec).

So netchannels with userspace stack behave exactly the same in both 128
and 1024 byte write/read cases.

But all it is just a drawnbacks of userspace stack, not netchannels,
which do not have any protocol processing at all - it is just a queue
between low-level driver and users - some kind of high performance scalable 
packet socket with only selected addresses or tun/tap device.

> Thanks.
> 
> -- 
> http://www.PowerDNS.com      Open source, database driven DNS Software 
> http://netherlabs.nl              Open and Closed source services

-- 
	Evgeniy Polyakov
