From: Ray Lehtiniemi <rayl@mail.com>
Subject: Re: how to tune a pair of e1000 cards on intel e7501-based system?
Date: Sun, 5 Dec 2004 21:10:03 -0700
Message-ID: <20041206041002.GC7891@mail.com>
References: <20041206024437.GB7891@mail.com> <1102304058.3343.217.camel@sfeldma-mobl.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
Content-Disposition: inline
In-Reply-To: <1102304058.3343.217.camel@sfeldma-mobl.dsl-verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Dec 05, 2004 at 07:34:18PM -0800, Scott Feldman wrote:
> On Sun, 2004-12-05 at 18:44, Ray Lehtiniemi wrote:
> > i'm trying to understand how to tune a pair of e1000 cards in
> > a server box.  the box is a dual xeon 3.06 with hyperthreading,
> > using the intel e7501 chipset, with both cards on hub interface
> > D.  the application involves small UDP packets, generally under
> 
> These are 82544 cards hanging of P64H2, so they're running at PCI-X, but
> at what speed?  Run ethtool -d eth<x> | grep Bus.

:-)  just found ethtool and compiled it before i read this email.  any other
useful tools i should get?



> The cards support
> 133Mhz, but having them adjacent on the same P64H2 probably bumps them
> down to 100Mhz.

# ethtool -d eth0 | grep Bus
      Bus type:                          PCI-X
      Bus speed:                         133MHz
      Bus width:                         64-bit
# ethtool -d eth1 | grep Bus
      Bus type:                          PCI-X
      Bus speed:                         133MHz
      Bus width:                         64-bit

so that looks okay...

any idea why lspci -vv shows non-64bit, non-133 MHz?  (i am assuming
that is what the minus sign means)

        Capabilities: [e4] PCI-X non-bridge device.
                Command: DPERE- ERO+ RBC=0 OST=0
                Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-



> Can you put one on D and the other on another bus?

not sure... have to look at the chassis tomorrow morning. a co-worker
actually built the box, i've not seen it in person yet.




> There is a lot of current traffic on netdev about this topic.  netdev is
> the official e1000 mailing this weekend.  :-)

i noticed that almost half of the messages in the e1000-devel archives
since oct 2002 were sent in the last 10 days :-)


> What kind of numbers are you getting?

will start testing tomorrow, just starting my background research tonight


> What kernel are you using?

2.4.20 with driver 4.4.12-k1, and 2.6.bkcurr with driver 5.bkcurr



> What driver tweaks have you made, if any?

none yet.  based on mailing list searches, i plan to:

 - InterruptThrottleRate 15000
 - TxIntDelay 0

i also plan to set rp_filter to zero for all interfaces.



thanks

-- 
----------------------------------------------------------------------
     Ray L   <rayl@mail.com>
