From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Extremely bad performance with RTL8111/8168B
Date: Tue, 9 Jul 2013 11:32:24 +0200
Message-ID: <20130709093224.GB20470@amd.pavel.ucw.cz>
References: <20130708095459.GA29788@amd.pavel.ucw.cz>
 <1373291269.4979.102.camel@edumazet-glaptop>
 <20130708220149.GA15766@electric-eye.fr.zoreil.com>
 <20130709000902.GB19366@amd.pavel.ucw.cz>
 <1373328752.4979.129.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:34646 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872Ab3GIJc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 05:32:26 -0400
Content-Disposition: inline
In-Reply-To: <1373328752.4979.129.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon 2013-07-08 17:12:32, Eric Dumazet wrote:
> On Tue, 2013-07-09 at 02:09 +0200, Pavel Machek wrote:
> 
> > BTW I'm on 100mbit switch, so advanced stuff needed for gigabit speed
> > is not too important for me. I may want to connect it with cross cable
> > in future, but for now...
> 
> Check "ethtool eth0" and make sure you are in full-duplex mode.

It seems that is not a problem... and I guess I have new speed record:

pavel@amd:~$ scp /tmp/delme pavel@duo:/tmp
pavel@duo's password: 
delme                                          66%   22MB  11.7KB/s - stalled -
/tmp/delme: Broken pipe
pavel@amd:~$ 

(No, I did not terminate the transfer, it just died :-().

root@duo:~# ethtool eth0
Settings for eth0:
	Supported ports: [ TP MII ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Half 1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Half 1000baseT/Full 
	Advertised pause frame use: Symmetric Receive-only
	Advertised auto-negotiation: Yes
	Link partner advertised link modes:  10baseT/Half 10baseT/Full 
	                                     100baseT/Half 100baseT/Full 
	Link partner advertised pause frame use: Symmetric
	Link partner advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: MII
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Supports Wake-on: pumbg
	Wake-on: g
	Current message level: 0x00000033 (51)
	Link detected: yes
root@duo:~# 

Hmm, that is slightly interesting. What is the pause stuff? e1000e on
the same switch reports:

Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 1
	Transceiver: internal
	Auto-negotiation: on
	MDI-X: on
	Supports Wake-on: pumbg
	Wake-on: g
	Current message level: 0x00000007 (7)
	Link detected: yes
root@amd:~# 

I tried 

root@duo:~# ethtool -A eth0 rx off tx off
Cannot get device pause settings: Operation not supported
root@duo:~# 

Also... Why it reports Port: MII instead of "twisted pair"?

Any other ideas?

Thanks,
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
