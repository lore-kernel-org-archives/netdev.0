From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 15:50:51 +0100
Message-ID: <20041205145051.GA647@xi.wantstofly.org>
References: <1101499285.1079.45.camel@jzny.localdomain> <16811.8052.678955.795327@robur.slu.se> <1101821501.1043.43.camel@jzny.localdomain> <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain> <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net> <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org> <1101967983.4782.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Robert Olsson <Robert.Olsson@data.slu.se>,
        P@draigBrady.com, mellia@prezzemolo.polito.it,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
Content-Disposition: inline
In-Reply-To: <1101967983.4782.9.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Dec 01, 2004 at 10:13:33PM -0800, Scott Feldman wrote:

> Idea#3
> 
> http://www.mail-archive.com/freebsd-net@freebsd.org/msg10826.html
> 
> Set TXDMAC to 0 in e1000_configure_tx.

Enabling 'DMA packet prefetching' gives me an impressive boost in performance.
Combined with your TX clean rework, I now get 1.03Mpps TX performance at 60B
packets.  Transmitting from both of the 82546 ports at the same time gives me
close to 2 Mpps.

The freebsd post hints that (some) e1000 hardware might be buggy w.r.t. this
prefetching though.

I'll play some more with the other ideas you suggested as well.

60      1036488
61      1037413
62      1036429
63      990239
64      993218
65      993233
66      993201
67      993234
68      993219
69      993208
70      992225
71      980560


--L


diff -ur e1000.orig/e1000_main.c e1000/e1000_main.c
--- e1000.orig/e1000_main.c	2004-12-04 11:43:12.000000000 +0100
+++ e1000/e1000_main.c	2004-12-05 15:40:49.284946897 +0100
@@ -879,6 +894,8 @@
 
 	E1000_WRITE_REG(&adapter->hw, TCTL, tctl);
 
+	E1000_WRITE_REG(&adapter->hw, TXDMAC, 0);
+
 	e1000_config_collision_dist(&adapter->hw);
 
 	/* Setup Transmit Descriptor Settings for eop descriptor */
