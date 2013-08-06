From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug: alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver
Date: Tue, 06 Aug 2013 03:43:19 -0700
Message-ID: <1375785799.4457.81.camel@edumazet-glaptop>
References: <CACtZaFJZCWigdT6_vsP9BTRSORzumu33xUtyPtpiDuNn3DQi+w@mail.gmail.com>
	 <20130805225752.14e843f7@nehalam.linuxnetplumber.net>
	 <CACtZaF+nTHiZ03uebya92b=UVLBXAk9jnM-=Pp3GQ6oSNv8ndA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>
To: Kinley Dorji <kinleyd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:55269 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755772Ab3HFKnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 06:43:21 -0400
Received: by mail-pd0-f180.google.com with SMTP id 15so193774pdi.25
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 03:43:21 -0700 (PDT)
In-Reply-To: <CACtZaF+nTHiZ03uebya92b=UVLBXAk9jnM-=Pp3GQ6oSNv8ndA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 12:05 +0600, Kinley Dorji wrote:
> No sure what conky is using to read them. This is what I get
> 
> $ ip -s -d li show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
> state UP mode DEFAULT qlen 1000
>     link/ether 90:2b:34:da:42:fd brd ff:ff:ff:ff:ff:ff promiscuity 0
>     RX: bytes  packets  errors  dropped overrun mcast
>     0          0        0       62      0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     0          0        0       0       0       0
> 
> $ ethtool -S eth0
> no stats available

It seems alx driver does not support stats.

(No ndo_get_stats() and no changes on netdev->stats embedded stats)


drivers/net/ethernet/atheros/atl1c/atl1c_main.c provides
atl1c_get_stats() gathering hardware counters

CC Johannes Berg, let see if he has plan to add them on alx
