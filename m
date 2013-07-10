From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Extremely bad performance with RTL8111/8168B
Date: Wed, 10 Jul 2013 15:41:04 +0200
Message-ID: <20130710134104.GA4086@amd.pavel.ucw.cz>
References: <20130708095459.GA29788@amd.pavel.ucw.cz>
 <1373291269.4979.102.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:41768 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab3GJNlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 09:41:06 -0400
Content-Disposition: inline
In-Reply-To: <1373291269.4979.102.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> > I've small Intel desktop with RTL8111/8168B ethernet... but the
> > performance is extremely bad.
> > 
> > In 3.10, I only get about 200KB/sec:
> > 
> > pavel@amd:~$ scp /tmp/delme pavel@duo:/tmp
> > pavel@duo's password: 
> > delme                                               100%   16MB
> > 236.0KB/s   01:09    
> > 
> > In older version, I get 1MB/s, but network fails every 10 minutes or
> > so. Card is:
> > 
> > 03:00.0 Ethernet controller: Realtek Semiconductor Co.,
> > Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 03)
> > 
> > I did install firmware-realtek package as suggested by debian
> > installer.
> > 
> > Dmesg says:
> > 
> > r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> > r8169 0000:03:00.0 eth0: RTL8168d/8111d at 0xf8010000,
> > 00:27:0e:2a:43:71, XID 081000c0 IRQ 17
> > r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 bytes, tx
> > checksumming: ko]
> > 
> > Any ideas what is wrong?
> 
> Hi Pavel
> 
> I guess receiving is OK ?

Actually, receiving is slow. Transmit is ok. "duo" is "bad" machine
with RTL card.

pavel@amd:~/misc/hw/duo$ scp /tmp/delme pavel@duo:/tmp
pavel@duo's password: 
delme 17%   35MB 759.1KB/s   03:39 ETA
(I aborted the copy).
pavel@amd:~/misc/hw/duo$ scp pavel@duo:/tmp/delme /tmp
pavel@duo's password: 
delme 100%   34MB  11.3MB/s   00:03    
pavel@amd:~/misc/hw/duo$ ping duo
PING duo (10.0.0.9) 56(84) bytes of data.
64 bytes from duo (10.0.0.9): icmp_req=1 ttl=64 time=1.17 ms
64 bytes from duo (10.0.0.9): icmp_req=2 ttl=64 time=0.737 ms
64 bytes from duo (10.0.0.9): icmp_req=3 ttl=64 time=1.17 ms
64 bytes from duo (10.0.0.9): icmp_req=4 ttl=64 time=0.608 ms

(I even out-of-tree driver for 2.6.32, and it seemed to have similar
problems.)


> It looks like TSO packets are not transmitted, so TCP only 'works'
> because retransmits use non TSO packets.
> 
> Could you report "ethtool -k eth0" ?

Yes:

root@duo:~# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: off
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: on
large-receive-offload: off
ntuple-filters: off
receive-hashing: off

> try : ethtool -K eth0 tso off

No, that does not help:

pavel@amd:~$ scp /tmp/delme pavel@duo:/tmp
pavel@duo's password: 
delme 100%   34MB 706.9KB/s 00:49    

[Now... I plugged old J2585B 10/100VG PCI card into the duo...
full-height card into half-height slot, oops... only to discover that
it can't do 100mbit ethernet. I guess "100VG" means "not 100 mbit" :-(.]

Any other ideas? :-),

									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
