From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [E1000-devel] Transmission limit
Date: Wed, 1 Dec 2004 16:34:12 +0100
Message-ID: <16813.58484.343629.570703@robur.slu.se>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	<41A73826.3000109@draigBrady.com>
	<16807.20052.569125.686158@robur.slu.se>
	<1101484740.24742.213.camel@mellia.lipar.polito.it>
	<41A76085.7000105@draigBrady.com>
	<1101499285.1079.45.camel@jzny.localdomain>
	<16811.8052.678955.795327@robur.slu.se>
	<1101821501.1043.43.camel@jzny.localdomain>
	<20041130134600.GA31515@xi.wantstofly.org>
	<1101824754.1044.126.camel@jzny.localdomain>
	<20041201001107.GE4203@xi.wantstofly.org>
	<1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, jamal <hadi@cyberus.ca>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sfeldma@pobox.com
In-Reply-To: <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Scott Feldman writes:
 > Hey, turns out, I know some e1000 tricks that might help get the kpps
 > numbers up.  
 > 
 > My problem is I only have a P4 desktop system with a 82544 nic running
 > at PCI 32/33Mhz, so I can't play with the big boys.  But, attached is a
 > rework of the Tx path to eliminate 1) Tx interrupts, and 2) Tx
 > descriptor write-backs.  For me, I see a nice jump in kpps, but I'd like
 > others to try with their setups.  We should be able to get to wire speed
 > with 60-byte packets.
 > 
 > System: Intel 865 (HT 2.6Ghz)
 > Nic: 82544 PCI 32-bit/33Mhz
 > Driver: linux-2.6.9 e1000 (5.3.19-k2-NAPI), no Interrupt Delays

 > 4096 descs
 >   pkt_size = 60:   541618pps 277Mb/sec errors: 914

Hello!

Nice but I no improvements w. 82546GB @ 133 MHz on 1.6 GHz Opteron it seems.
SMP kernel linux-2.6.9-rc2

Vanilla. 
  801077pps 410Mb/sec (410151424bps) errors: 95596

Patch TXD=4096
  608690pps 311Mb/sec (311649280bps) errors: 0

Patch TXD=2048
  624103pps 319Mb/sec (319540736bps) errors: 0

Patch TXD=1024
  551289pps 282Mb/sec (282259968bps) errors: 4506

Error count is a bit confusing...

						--ro
