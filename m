From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Wed, 09 Mar 2005 13:14:16 +1100
Message-ID: <1110334456.32556.21.camel@gaston>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
        Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-08 at 19:47 -0600, Andy Fleming wrote:
> I've finally gotten all of ebs's suggestions into the PHY code.  Here 
> is the new version.  It has the following improvements:
> 
> * All PHYs now determine speed,duplex, etc using the same generic code, 
> rather than PHY-specific registers.

Some PHY are doing a better job with PHY specific registers I think ...
The gigabit for example isn't standard, and some PHYs sort-of manage to
deal with non-autoneg hubs in such a way that the "normal" aneg doesn't
succeeds, but the phy specific stuff does work. At least from stuff I've
been told a while ago, I have no direct experience here.

> * The genphy driver works for gigabit PHYs now, as well.  In theory, if 
> your PHY isn't broken in some way (I've encountered a number that are), 
> you should be able to just use genphy.

Isn't the speed reporting of gigabit an implementation specific bit in
lots of PHYs ?

> * The genphy driver now detects what features the PHY has, rather than 
> relying on arbitrarily hard-coded values
> 
> * Pause negotiation and advertising has been added
> 
> * PHY read and write functions now return errors if the bus read/write 
> functions return errors.  These errors are handled properly, and should 
> not cause any problem.  It is the bus's responsibility, however, to 
> make sure that the PHY is started again once the error is cleared.
> 
> This patch contains just the PHY code.  A later email will contain the 
> gianfar driver and 85xx patches, which will serve as an example for how 
> to use the PHY code.
> 
> A note about size:  I did some rough size comparisons, and it looks 
> like this code adds ~10 K to the binary size of the kernel (for PPC 32, 
> 85xx).  However, that's a rough estimate, since my tree includes 
> features added to the gianfar driver (eg: ethtool support for setting 
> speed/duplex).

I'll have a closer look when I find some time, see if it makes sense to
adapt sungem or not.

Ben.
