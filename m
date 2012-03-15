From: Timo Teras <timo.teras@iki.fi>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and
 performance degration
Date: Thu, 15 Mar 2012 08:06:35 +0200
Message-ID: <20120315080635.1f76512b@vostro>
References: <20120314190156.622c8cd5@vostro>
	<1331745314.6022.27.camel@edumazet-glaptop>
	<20120314192945.65867e9f@vostro>
	<1331753354.2564.7.camel@bwh-desktop.uk.solarflarecom.com>
	<20120314215142.655ae607@vostro>
	<1331755965.6022.55.camel@edumazet-glaptop>
	<20120314223343.23dc9df3@vostro>
	<20120314205319.GA28394@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49331 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753182Ab2COGHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 02:07:17 -0400
Received: by wejx9 with SMTP id x9so2451518wej.19
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 23:07:16 -0700 (PDT)
In-Reply-To: <20120314205319.GA28394@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Mar 2012 21:53:19 +0100 Francois Romieu
<romieu@fr.zoreil.com> wrote:

> Timo Teras <timo.teras@iki.fi> :
> [...]
> > # ethtool -S eth2
> > NIC statistics:
> >      tx_packets: 2069391193
> >      rx_packets: 3245815642
> >      tx_errors: 0
> >      rx_errors: 645238
> >      rx_missed: 31414
> 
> It does not look like stuff for the higher layers guys.
> 
> Can you tshark -w foobar on the sender side and
> 'while : ; do sleep 1; ethtool -S eth2 >> glop; done' on the receiver
> during a bad wget (a big zero filled file should compress well).

Indeed.

It seems that my earlier test about the "GRO off" effect were mistaken
(I used accidentally proxy, and that gave the illusion that things are
working. Whoops.)

So far I changed the cross-over cable and it didn't help. However,
forcing the NIC to 100mbit/full-duplex mode fixes the rx_errors. It
seems that something bad is happening in the gigabit mode.

# ethtool eth2
Settings for eth2:
	Supported ports: [ TP MII ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Half 1000baseT/Full 
	Supported pause frame use: No
	Supports auto-negotiation: Yes
	Advertised link modes:  100baseT/Full 
	Advertised pause frame use: Symmetric Receive-only
	Advertised auto-negotiation: Yes
	Link partner advertised link modes:  10baseT/Half 10baseT/Full 
	                                     100baseT/Half 100baseT/Full 
	Link partner advertised pause frame use: Symmetric Receive-only
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
			       drv probe ifdown ifup
	Link detected: yes


I wonder if it's using pause frames and that's messing things up. Seems
that I can't turn it off, though.

I can also double check my cables, though it is factory made Cat-5E
cross-over cable; and happens with two different cables.

-Timo
