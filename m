From: Grant Grundler <iod00d@hp.com>
Subject: Re: [PATCH] tg3_msi() and weakly ordered memory
Date: Tue, 14 Jun 2005 08:46:25 -0700
Message-ID: <20050614154625.GB24371@esmail.cup.hp.com>
References: <B1508D50A0692F42B217C22C02D84972067F0805@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, iod00d@hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <B1508D50A0692F42B217C22C02D84972067F0805@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2005 at 11:54:23PM -0700, Michael Chan wrote:
> > Once you write "0x1" to the mailbox register, the device stops
> > updating the status block and stops generating interrupts.
> > 
> > That is what makes a lot of things safe.
> 
> Only interrupts are stopped, status block will still be updated subject to
> during-ints coalescing.

Will setting during-ints to a very high threshhold essentially allow
us to "indefinitely" process stuff without taking any interrupts?
Would the threshhold counter get reset every time we write back
the status tag WITHOUT re-enableing interrupts?

If not, I suspect the CPU will circulate in tg3_poll until during-ints
is exhausted and DMA will stop until CPU reenables interrupts.
ie not until it's done processing outstanding packets.

thanks,
grant
