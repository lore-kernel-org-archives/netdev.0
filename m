From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 17:48:34 +0100 (CET)
Message-ID: <Pine.LNX.4.58.0412051730010.29474@tux.rsn.bth.se>
References: <1101499285.1079.45.camel@jzny.localdomain>
 <16811.8052.678955.795327@robur.slu.se> <1101821501.1043.43.camel@jzny.localdomain>
 <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain>
 <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
 <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org>
 <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org>
 <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se>
 <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Scott Feldman <sfeldma@pobox.com>, jamal <hadi@cyberus.ca>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Dec 2004, Martin Josefsson wrote:

> The delayed TDT updating was a test and currently it delays the first tx'd
> packet after a timerrun 1ms.

I removed the delayed TDT updating and gave it a go again (this is scott +
prefetching):

60      1486193
64      1267639
68      1259682
72      1243997
76      1243989
80      1153608
84      1123813
88      1115047
92      1076636
96      1040792
100     1007252
104     975806
108     946263
112     918456
116     892227
120     867477
124     844052
128     821858

It gives a little diffrent results, 60byte is ok but then it falls a lot
down to 64byte and the curve seems a bit flatter.

This should be the same driver that Lennert got 1.03Mpps with.
I get 1.03Mpps without prefetching.

I tried using both ports on the 82546GB nic.

        delay        nodelay
1CPU    1.95 Mpps    1.76 Mpps
2CPU    1.60 Mpps    1.44 Mpps

All tests performed on an SMP kernel, the above mention of 1CPU vs 2CPU
just means how the two nics were bound to the cpus. And there's no
tx-interrupts at all due to scotts patch.

/Martin
