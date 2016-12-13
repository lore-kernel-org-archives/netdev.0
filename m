From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store
 multicast entries
Date: Tue, 13 Dec 2016 16:09:48 +0100
Message-ID: <20161213150948.GD20323@lunn.ch>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
 <87r35db35m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAMr9Lbp5eCg1oyWGN+uiDEcF0VZuKUi87FH6JYTGj6pL82R+Mw@mail.gmail.com>
 <48ff1136-dd8f-7704-a512-c23b27989bf8@gmail.com>
 <20161212190915.GA8885@lunn.ch>
 <CAMr9LbqyvrRYe_m34Ufzxkf2Vef3LbMQiuoiwVX0mK=hW6euyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
To: Volodymyr Bendiuga <valdr.linuxnext@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53521 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933750AbcLMPJw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Dec 2016 10:09:52 -0500
Content-Disposition: inline
In-Reply-To: <CAMr9LbqyvrRYe_m34Ufzxkf2Vef3LbMQiuoiwVX0mK=hW6euyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Another interesting thing is that fdb dump operation is slow
> too. The more entries you have the slower it gets. We have
> implemented caching with timing there as well (I have not submitted
> such patch yet), which makes fdb dump much more pleasant in user
> space, the operation happens instantly, where regular fdb dump op
> might take few seconds.

I know some people won't like the added MDIO transactions, because
they are doing PTP and want low jitter when talking to the switch and
PHYs. As things are now, once the system is configured, the MDIO bus
is idle. Hence there is very low jitter for PTP. For your cache to be
useful, i assume you are refreshing it at regular intervals. So you
are adding a constant load, which i guess 99.9% of the timer is never
used because there is no user looking at the table, where as the PTP
load is used to keep the clocks synchronised.

   Andrew
