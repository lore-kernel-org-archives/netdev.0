From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 22:25:59 +0100
Message-ID: <20041205212559.GA4338@xi.wantstofly.org>
References: <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain> <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net> <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org> <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org> <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se> <1102281141.3343.138.camel@sfeldma-mobl.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Josefsson <gandalf@wlug.westbo.se>, jamal <hadi@cyberus.ca>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
Content-Disposition: inline
In-Reply-To: <1102281141.3343.138.camel@sfeldma-mobl.dsl-verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Dec 05, 2004 at 01:12:22PM -0800, Scott Feldman wrote:

> Would Martin or Lennert run these test for a longer duration so we can
> get some data, maybe adding in Rx.  It could be that removing the Tx
> interrupts and descriptor write-backs, prefetching may be ok.  I don't
> know.  Intel?

What your patch does is (correct me if I'm wrong):
- Masking TXDW, effectively preventing it from delivering TXdone ints.
- Not setting E1000_TXD_CMD_IDE in the TXD command field, which causes
  the chip to 'ignore the TIDV' register, which is the 'TX Interrupt
  Delay Value'.  What exactly does this?
- Not setting the "Report Packet Sent"/"Report Status" bits in the TXD
  command field.  Is this the equivalent of the TXdone interrupt?

Just exactly which bit avoids the descriptor writeback?

I'm also a bit worried that only freeing packets 1ms later will mess up
socket accounting and such.  Any ideas on that?


> Also, wouldn't it be great if someone wrote a document capturing all of
> the accumulated knowledge for future generations?

I'll volunteer for that.


--L
