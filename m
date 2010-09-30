From: Alexey Vlasov <renton@renton.name>
Subject: Re: Packet time delays on multi-core systems
Date: Thu, 30 Sep 2010 16:23:21 +0400
Message-ID: <20100930122321.GA1575@beaver.vrungel.ru>
References: <20100929191851.GC86786@beaver.vrungel.ru> <1285796721.5211.156.camel@edumazet-laptop> <20100930062419.GD86786@beaver.vrungel.ru> <1285828432.5211.812.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1285828432.5211.812.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 30, 2010 at 08:33:52AM +0200, Eric Dumazet wrote:
> Le jeudi 30 septembre 2010 ?? 10:24 +0400, Alexey Vlasov a ??crit :
> > Here I found some dude with the same problem:
> > http://lkml.org/lkml/2010/7/9/340
> > 
> 
> In your opinion its the same problem.
> 
> But the description you gave is completely different.
> 
> You have time skew only when activating a particular iptables rule.
 
Well I put interrups from NIC, namely tx/rx query, to different
processors and got normal pings by adding LOG rule.

I also found that overruns is constantly growing, I don't know if these are connected.
RX packets:2831439546 errors:0 dropped:134726 overruns:947671733 frame:0
TX packets:2880849825 errors:0 dropped:0 overruns:0 carrier:0

Rather strange that only one processor was involved, even in top was
clear that ksoftirqd eats the first processor up to 100%. 

Here goes the typical distribution of interrups on new servers:
           CPU0    CPU1    CPU2    CPU3 ... CPU23
752:         11       0       0       0 ...     0 PCI-MSI-edge eth0
753: 2799366721       0       0       0 ...     0 PCI-MSI-edge eth0-rx3
754: 2821840553       0       0       0 ...     0 PCI-MSI-edge eth0-rx2
755: 2786117044       0       0       0 ...     0 PCI-MSI-edge eth0-rx1
756: 2896099336       0       0       0 ...     0 PCI-MSI-edge eth0-rx0
757: 1808404680       0       0       0 ...     0 PCI-MSI-edge eth0-tx3
758: 1797855130       0       0       0 ...     0 PCI-MSI-edge eth0-tx2
759: 1807222032       0       0       0 ...     0 PCI-MSI-edge eth0-tx1
760: 1820309360       0       0       0 ...     0 PCI-MSI-edge eth0-tx0

On the old ones:
           CPU0       CPU1       CPU2  ...      CPU8
502:  522320256  522384039  522327386  ... 522380267 PCI-MSI-edge eth0

-- 
BRGDS. Alexey Vlasov.
