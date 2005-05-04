From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: Mystery packet killing tg3
Date: Tue, 3 May 2005 23:09:15 -0700
Message-ID: <B1508D50A0692F42B217C22C02D84972020F3EB1@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: shemminger@osdl.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> I can't think of what else could be wedging the tg3.  
> Michael, any ideas?  There are some 5703 specific programming 
> to consider:
> 
The 5703 related settings in tg3 seem ok to me too.

If Stephen says the stop_block error happens during normal ifdown and traffic
was otherwise working fine before ifdown, then I think it may not even be a
problem at all.

Stopping the various state machines can be tricky and I'm not at all
surprised that some state machines can fail to stop in some cases. They are
all interconnected and even if you follow the stopping sequence in the
programmer's reference manual, you may still end up with a situation where
one state machine is waiting for another that has been stopped already. This
is not a problem as tg3_stop_block() calls are always followed by a global
chip reset that will clean up the whole chip. The purpose of tg3_stop_block()
is to quiesce the chip and complete all DMA transactions before abruptly
resetting the chip. If the DMA blocks would not stop, then it would be a
bigger problem.

Other tg3_stop_block() errors that I've seen, such as the ones reported by
John Linville, were preceded by netdev watchdog timeouts. These netdev
watchdog timeouts were real problems that needed to be solved.
