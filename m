From: jamal <hadi@cyberus.ca>
Subject: RE: [RFC,PATCH] fastroute dead code...
Date: 30 Jul 2004 17:05:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1091221502.1032.547.camel@jzny.localdomain>
References: <9DFF23E1E33391449FDC324526D1F25902833769@sjc1exm02.pmc_nt.nt.pmc-sierra.bc.ca>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, tmattox@gmail.com, netdev@oss.sgi.com,
        Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manish Lachwani <Manish_Lachwani@pmc-sierra.com>
In-Reply-To: <9DFF23E1E33391449FDC324526D1F25902833769@sjc1exm02.pmc_nt.nt.pmc-sierra.bc.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-07-30 at 16:31, Manish Lachwani wrote:
> Is this a 2.6 issue or a 2.4 issue? This is because I am using 2.4.21 
> kernel and so do the customers of the board. This board supports 1.0 
> Ghz PMC-Sierra Rm9000 processor. With fast routing, the IP forwarding 
> numbers are about 900 Kpps. While in the case where there is no fast 
> routing, the numbers are about 450 Kpps (NAPI enabled)

There could be many reasons why this is happening. Lets start with some
simple experiment:

- drop packets in netif_receive_skb(); this way they get counted
by the driver stats but they dont get transfered. Count the rate at
which you can receive packets.
- On net/core/dev.c comment out do_gettimeofday() in netif_receive_skb()
and do some measurement with regular routing.
- repeat same tests with droping at netif_receive_skb().

When you are forwarding, try to collect qdisc stats on egress as well
so we could see if you are bus bound. I have a feeling this will never
be a problem for you - those mups things normaly have some obscenely
fast bus compared to say er PCI.

> I still have not done any 2.6 benchmarking since the board support is 
> not completely functional in 2.6 as yet. 

You will see improvements in 2.6.x.


cheers,
jamal
