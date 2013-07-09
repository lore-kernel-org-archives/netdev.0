From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Extremely bad performance with RTL8111/8168B
Date: Wed, 10 Jul 2013 00:29:51 +0100
Message-ID: <1373412591.2523.7.camel@bwh-desktop.uk.level5networks.com>
References: <20130708095459.GA29788@amd.pavel.ucw.cz>
	 <1373291269.4979.102.camel@edumazet-glaptop>
	 <20130708220149.GA15766@electric-eye.fr.zoreil.com>
	 <20130709000902.GB19366@amd.pavel.ucw.cz>
	 <1373328752.4979.129.camel@edumazet-glaptop>
	 <20130709093224.GB20470@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>, <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33472 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545Ab3GIX3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 19:29:55 -0400
In-Reply-To: <20130709093224.GB20470@amd.pavel.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-09 at 11:32 +0200, Pavel Machek wrote:
> On Mon 2013-07-08 17:12:32, Eric Dumazet wrote:
> > On Tue, 2013-07-09 at 02:09 +0200, Pavel Machek wrote:
> > 
> > > BTW I'm on 100mbit switch, so advanced stuff needed for gigabit speed
> > > is not too important for me. I may want to connect it with cross cable
> > > in future, but for now...
> > 
> > Check "ethtool eth0" and make sure you are in full-duplex mode.
> 
> It seems that is not a problem... and I guess I have new speed record:
> 
> pavel@amd:~$ scp /tmp/delme pavel@duo:/tmp
> pavel@duo's password: 
> delme                                          66%   22MB  11.7KB/s - stalled -
> /tmp/delme: Broken pipe
> pavel@amd:~$ 
> 
> (No, I did not terminate the transfer, it just died :-().
> 
> root@duo:~# ethtool eth0
> Settings for eth0:
> 	Supported ports: [ TP MII ]
> 	Supported link modes:   10baseT/Half 10baseT/Full 
> 	                        100baseT/Half 100baseT/Full 
> 	                        1000baseT/Half 1000baseT/Full 
> 	Supports auto-negotiation: Yes
> 	Advertised link modes:  10baseT/Half 10baseT/Full 
> 	                        100baseT/Half 100baseT/Full 
> 	                        1000baseT/Half 1000baseT/Full 
> 	Advertised pause frame use: Symmetric Receive-only
> 	Advertised auto-negotiation: Yes
> 	Link partner advertised link modes:  10baseT/Half 10baseT/Full 
> 	                                     100baseT/Half 100baseT/Full 
> 	Link partner advertised pause frame use: Symmetric
> 	Link partner advertised auto-negotiation: Yes
[...]
> Hmm, that is slightly interesting. What is the pause stuff? e1000e on
> the same switch reports:
>
> Settings for eth0:
> 	Supported ports: [ TP ]
> 	Supported link modes:   10baseT/Half 10baseT/Full 
> 	                        100baseT/Half 100baseT/Full 
> 	                        1000baseT/Full 
> 	Supports auto-negotiation: Yes
> 	Advertised link modes:  10baseT/Half 10baseT/Full 
> 	                        100baseT/Half 100baseT/Full 
> 	                        1000baseT/Full 
> 	Advertised pause frame use: No

e1000e doesn't report the advertised pause frame flags (or any link
partner advertising flags).

> 	Advertised auto-negotiation: Yes
> 	Speed: 100Mb/s
> 	Duplex: Full
> 	Port: Twisted Pair
> 	PHYAD: 1
> 	Transceiver: internal
> 	Auto-negotiation: on
> 	MDI-X: on
> 	Supports Wake-on: pumbg
> 	Wake-on: g
> 	Current message level: 0x00000007 (7)
> 	Link detected: yes
> root@amd:~# 
> 
> I tried 
> 
> root@duo:~# ethtool -A eth0 rx off tx off
> Cannot get device pause settings: Operation not supported
> root@duo:~# 
> 
> Also... Why it reports Port: MII instead of "twisted pair"?

Minor bug in r8169, not really relevant.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
